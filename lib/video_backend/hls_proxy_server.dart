import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:strumok/utils/hls.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/utils.dart';

/// An HLS-aware reverse proxy that runs on localhost.
///
/// It exposes three endpoints:
///
/// * `GET /master?url=<encoded>`
///   Fetches the master playlist from [url], parses it, and rewrites every
///   stream URI to point at `/stream?url=<encoded-stream-url>`.
///
/// * `GET /stream?url=<encoded>`
///   Fetches a media-segment playlist from [url], parses it, and rewrites
///   segment URIs → `/segment?url=…`. EXT-X-KEY URIs are left unchanged so
///   the player fetches decryption keys directly from the origin.
///
/// * `GET /segment?url=<encoded>`
///   Proxies raw TS bytes, stripping any leading junk (e.g. 1×1 PNG tracking
///   pixels) before the first confirmed MPEG-TS sync byte (0x47).
///
/// Usage:
/// ```dart
/// final proxy = HLSProxyServer(
///   port: 8888,
/// );
/// await proxy.start();
///
/// // Point the player at the proxy master URL:
/// final playerUrl = proxy.masterUrl('https://cdn.example.com/live/master.m3u8');
///
/// await proxy.stop();
/// ```
class HLSProxyServer {
  final int port;

  HttpServer? _server;
  final http.Client _httpClient = http.Client();

  HLSProxyServer({required this.port});

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Base URL of this proxy, e.g. `http://localhost:8888`.
  String get baseUrl => 'http://localhost:$port';

  /// Whether the server is currently running.
  bool get isRunning => _server != null;

  /// Returns the proxied master-playlist URL for [upstreamUrl].
  Uri masterUrl(Uri upstreamUrl) => Uri.parse(
    '$baseUrl/master?url=${Uri.encodeComponent(upstreamUrl.toString())}',
  );

  /// Starts the HTTP server and begins handling requests.
  Future<void> start() async {
    if (_server != null) {
      logger.warning('[HLSProxyServer] Already running on port $port');
      return;
    }

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    logger.info('[HLSProxyServer] Listening on $baseUrl');

    _server!.listen(
      _dispatch,
      onError: (Object error, StackTrace stack) {
        logger.severe('[HLSProxyServer] Server error', error, stack);
      },
    );
  }

  /// Stops the HTTP server and closes the HTTP client.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _httpClient.close();
    logger.info('[HLSProxyServer] Stopped');
  }

  // ---------------------------------------------------------------------------
  // Request dispatcher
  // ---------------------------------------------------------------------------

  Future<void> _dispatch(HttpRequest req) async {
    logger.fine('[HLSProxyServer] ${req.method} ${req.uri}');
    try {
      switch (req.uri.path) {
        case '/master':
          await _handleMaster(req);
        case '/stream':
          await _handleStream(req);
        case '/segment':
          await _handleSegment(req);
        default:
          req.response.statusCode = HttpStatus.notFound;
          logger.severe('[HLSProxyServer] Not found: ${req.uri.path}');
          await req.response.close();
      }
    } catch (error, stack) {
      logger.severe(
        '[HLSProxyServer] Unhandled error for ${req.uri}',
        error,
        stack,
      );
      try {
        req.response.statusCode = HttpStatus.internalServerError;
        await req.response.close();
      } catch (_) {
        // response may already be closed
      }
    }
  }

  // ---------------------------------------------------------------------------
  // /master endpoint
  // ---------------------------------------------------------------------------

  Future<void> _handleMaster(HttpRequest req) async {
    final upstreamUri = _requireUpstreamUri(req);
    if (upstreamUri == null) return;

    final content = await _fetchText(req);
    if (content == null) {
      req.response.statusCode = HttpStatus.badGateway;
      logger.severe('[HLSProxyServer] Failed to fetch master playlist');
      await req.response.close();
      return;
    }

    final rewritten = _rewriteStreamPlaylist(upstreamUri, content);

    req.response.statusCode = HttpStatus.ok;
    req.response.headers.contentType = _hlsContentType;
    req.response.write(rewritten);
    await req.response.close();
  }

  // ---------------------------------------------------------------------------
  // /stream endpoint
  // ---------------------------------------------------------------------------

  Future<void> _handleStream(HttpRequest req) async {
    final upstreamUri = _requireUpstreamUri(req);
    if (upstreamUri == null) return;

    final content = await _fetchText(req);
    if (content == null) {
      req.response.statusCode = HttpStatus.badGateway;
      await req.response.close();
      return;
    }

    final rewritten = _rewriteStreamPlaylist(upstreamUri, content);

    req.response.statusCode = HttpStatus.ok;
    req.response.headers.contentType = _hlsContentType;
    req.response.write(rewritten);
    await req.response.close();
  }

  // ---------------------------------------------------------------------------
  // /segment endpoint – proxies TS data, stripping leading junk
  // ---------------------------------------------------------------------------

  /// Streams the segment to the client, discarding any leading junk bytes
  /// (e.g. a 1×1 PNG tracking pixel) that appear before the first confirmed
  /// MPEG-TS sync byte (0x47).
  ///
  /// Only the bytes needed to *detect* the sync position are ever held in
  /// memory. Once the sync is confirmed the handler switches to direct
  /// chunk-passthrough so the rest of the segment is forwarded immediately
  /// without any additional buffering.
  Future<void> _handleSegment(HttpRequest req) async {
    final upstreamUri = _requireUpstreamUri(req);
    if (upstreamUri == null) return;
    try {
      final upstreamReq = http.Request(req.method, upstreamUri);
      req.headers.forEach((name, values) {
        if (!_isHopByHopHeader(name)) {
          upstreamReq.headers[name] = values.join(', ');
        }
      });

      final streamedResponse = await _httpClient.send(upstreamReq);

      if (streamedResponse.statusCode >= 400) {
        logger.warning(
          '[HLSProxyServer] Upstream ${streamedResponse.statusCode} for $upstreamUri',
        );
        req.response.statusCode = streamedResponse.statusCode;
        await req.response.close();
        return;
      }

      // Forward safe upstream headers, then force TS content-type.
      req.response.statusCode = streamedResponse.statusCode;
      req.response.headers.contentType = ContentType('video', 'mp2t');

      final filter = TSJunkFilter();

      await for (final chunk in streamedResponse.stream) {
        final filtered = filter.feed(chunk);
        if (filtered != null) {
          req.response.add(filtered);
        }
      }

      // End of stream – flush whatever remains in the buffer.
      if (!filter.syncFound) {
        throw Exception('No MPEG-TS sync found in segment');
      } else if (filter.filteredBytes > 0) {
        logger.info(
          '[HLSProxyServer] Stripped ${filter.filteredBytes} leading junk bytes from $upstreamUri',
        );
      }

      await req.response.close();
    } catch (error, stack) {
      if (error is http.ClientException &&
          error.message.startsWith(
            'ClientException: Connection closed while receiving data',
          )) {
      } else {
        logger.severe(
          '[HLSProxyServer] Segment passthrough failed for $upstreamUri',
          error,
          stack,
        );
      }
      try {
        req.response.statusCode = HttpStatus.badGateway;
        await req.response.close();
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // HLS manifest rewriting
  // ---------------------------------------------------------------------------

  /// Rewrites a media-segment playlist so that segment URIs point at
  /// `/segment?url=<encoded>`. EXT-X-KEY URIs are left unchanged so the
  /// player fetches decryption keys directly from the origin.
  String _rewriteStreamPlaylist(Uri upstreamUri, String originalContent) {
    bool isMaster = false;

    final lines = LineSplitter.split(originalContent);
    final output = StringBuffer();

    for (final line in lines) {
      if (line.startsWith('#')) {
        if (line.startsWith('#EXT-X-STREAM-INF')) {
          isMaster = true;
        }
        output.writeln(line);
      } else {
        if (isMaster) {
          output.writeln(_streamUrl(relativeUri(upstreamUri, line).toString()));
        } else {
          output.writeln(
            _segmentUrl(relativeUri(upstreamUri, line).toString()),
          );
        }
      }
    }

    return output.toString();
  }

  // ---------------------------------------------------------------------------
  // URL builders
  // ---------------------------------------------------------------------------

  String _streamUrl(String upstreamUrl) =>
      '$baseUrl/stream?url=${Uri.encodeComponent(upstreamUrl)}';

  String _segmentUrl(String upstreamUrl) =>
      '$baseUrl/segment?url=${Uri.encodeComponent(upstreamUrl)}';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts and validates the `url` query parameter. Writes a 400 and
  /// returns null when the parameter is missing or invalid.
  Uri? _requireUpstreamUri(HttpRequest req) {
    final raw = req.uri.queryParameters['url'];
    if (raw == null || raw.isEmpty) {
      req.response.statusCode = HttpStatus.badRequest;
      logger.severe('[HLSProxyServer] Missing required query parameter: url');
      req.response.close();
      return null;
    }
    try {
      return Uri.parse(raw);
    } catch (_) {
      req.response.statusCode = HttpStatus.badRequest;
      logger.severe('[HLSProxyServer] Invalid url parameter: $raw');
      req.response.close();
      return null;
    }
  }

  /// Fetches [uri] as UTF-8 text using [extraHeaders]. Returns null on error.
  Future<String?> _fetchText(HttpRequest req) async {
    final upstreamUri = _requireUpstreamUri(req);
    if (upstreamUri == null) return null;
    try {
      final upstreamReq = http.Request('GET', upstreamUri);
      req.headers.forEach((name, values) {
        if (!_isHopByHopHeader(name)) {
          upstreamReq.headers[name] = values.join(', ');
        }
      });

      logger.info(
        '[HLSProxyServer] Fetching $upstreamUri with headers: ${upstreamReq.headers}',
      );

      final response = await _httpClient.send(upstreamReq);

      if (response.statusCode > 400) {
        logger.warning(
          '[HLSProxyServer] Upstream returned ${response.statusCode} for $upstreamUri',
        );
        return null;
      }

      final bytes = await response.stream.toBytes();
      return utf8.decode(bytes);
    } catch (error, stack) {
      logger.severe(
        '[HLSProxyServer] Failed to fetch $upstreamUri',
        error,
        stack,
      );
      return null;
    }
  }

  static ContentType get _hlsContentType =>
      ContentType('application', 'vnd.apple.mpegurl');

  static bool _isHopByHopHeader(String name) {
    const hopByHop = {
      'connection',
      'keep-alive',
      'proxy-authenticate',
      'proxy-authorization',
      'te',
      'trailers',
      'transfer-encoding',
      'upgrade',
      'host',
    };
    return hopByHop.contains(name.toLowerCase());
  }
}
