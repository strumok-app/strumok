import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:strumok/utils/hls.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/http.dart';
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
/// * `GET /segment?url=<encoded>[&format=fmp4]`
///   Proxies TS bytes with leading junk stripped, or passes fMP4 media and
///   initialization sections through unchanged. Encrypted and EXT-X-BYTERANGE
///   segments use `passthrough=true` because their bytes or ranges must stay
///   aligned with the origin.
///
/// Every response has a known length and range requests are answered against
/// the bytes this proxy sends. FFmpeg's reconnect options otherwise treat EOF
/// on an unknown-length response as a dropped connection and fetch it again.
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
  http.Client? _httpClient;

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
    _httpClient = createAppHttpClient();
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
    if (!isRunning) {
      return;
    }

    await _server?.close(force: true);
    _server = null;
    _httpClient?.close();
    _httpClient = null;
    logger.info('[HLSProxyServer] Stopped');
  }

  // ---------------------------------------------------------------------------
  // Request dispatcher
  // ---------------------------------------------------------------------------

  Future<void> _dispatch(HttpRequest req) async {
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
    logger.fine('[HLSProxyServer] Handling /master for ${req.uri}');
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

    req.response.headers.contentType = _hlsContentType;
    await _sendBytes(req, utf8.encode(rewritten));
  }

  // ---------------------------------------------------------------------------
  // /stream endpoint
  // ---------------------------------------------------------------------------

  Future<void> _handleStream(HttpRequest req) async {
    logger.fine('[HLSProxyServer] Handling /stream for ${req.uri}');
    final upstreamUri = _requireUpstreamUri(req);
    if (upstreamUri == null) return;

    final content = await _fetchText(req);
    if (content == null) {
      req.response.statusCode = HttpStatus.badGateway;
      await req.response.close();
      return;
    }

    final rewritten = _rewriteStreamPlaylist(upstreamUri, content);

    req.response.headers.contentType = _hlsContentType;
    await _sendBytes(req, utf8.encode(rewritten));
  }

  // ---------------------------------------------------------------------------
  // /segment endpoint – filters TS data or passes fMP4 through unchanged
  // ---------------------------------------------------------------------------

  /// Sends the segment to the client, discarding any leading junk bytes
  /// (e.g. a 1×1 PNG tracking pixel) that appear before the first confirmed
  /// MPEG-TS sync byte (0x47).
  ///
  /// Full requests with a known upstream length are streamed once the sync
  /// position is known. Other TS requests are buffered so ranges can refer to
  /// the filtered bytes. Passthrough requests keep the origin's ranges.
  Future<void> _handleSegment(HttpRequest req) async {
    final isFMP4 = req.uri.queryParameters['format'] == 'fmp4';
    final isPassthrough =
        isFMP4 || req.uri.queryParameters['passthrough'] == 'true';
    logger.fine(
      '[HLSProxyServer] Handling /segment for ${req.uri} isFMP4: $isFMP4 isPassthrough: $isPassthrough',
    );

    final upstreamUri = _requireUpstreamUri(req);
    if (upstreamUri == null) return;

    try {
      final upstreamReq = _upstreamRequest(
        req,
        upstreamUri,
        method: req.method,
        forwardRange: isPassthrough,
      );

      final streamedResponse = await _httpClient!.send(upstreamReq);

      if (streamedResponse.statusCode >= 400) {
        logger.warning(
          '[HLSProxyServer] Upstream ${streamedResponse.statusCode} for $upstreamUri',
        );
        req.response.statusCode = streamedResponse.statusCode;
        await req.response.close();
        return;
      }

      req.response.headers.contentType = ContentType(
        'video',
        isFMP4 ? 'mp4' : 'mp2t',
      );
      if (isPassthrough) {
        await _sendPassthrough(req, streamedResponse);
      } else {
        await _sendFilteredTS(req, streamedResponse, upstreamUri);
      }
    } catch (error, stack) {
      if (error is http.ClientException &&
          error.message.startsWith('Connection closed')) {
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

  Future<void> _sendPassthrough(
    HttpRequest req,
    http.StreamedResponse upstream,
  ) async {
    final res = req.response;
    res.statusCode = upstream.statusCode;
    for (final name in ['content-range', 'accept-ranges']) {
      final value = upstream.headers[name];
      if (value != null) {
        res.headers.set(name, value);
      }
    }

    final length = upstream.contentLength;
    if (length != null) {
      res.contentLength = length;
      await res.addStream(upstream.stream);
    } else {
      final bytes = await upstream.stream.toBytes();
      res.contentLength = bytes.length;
      res.add(bytes);
    }
    await res.close();
  }

  Future<void> _sendFilteredTS(
    HttpRequest req,
    http.StreamedResponse upstream,
    Uri upstreamUri,
  ) async {
    final res = req.response;
    final filter = TSJunkFilter();
    final rangeHeader = req.headers.value(HttpHeaders.rangeHeader)?.trim();
    final upstreamLength = upstream.contentLength;

    void logStripped() {
      if (filter.filteredBytes > 0) {
        logger.fine(
          '[HLSProxyServer] Stripped ${filter.filteredBytes} leading junk bytes from $upstreamUri',
        );
      }
    }

    if (upstreamLength != null &&
        (rangeHeader == null || rangeHeader == 'bytes=0-')) {
      var headersReady = false;
      void add(List<int> data) {
        if (!headersReady) {
          headersReady = true;
          final length = upstreamLength - filter.filteredBytes;
          res.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
          if (rangeHeader == null) {
            res.statusCode = HttpStatus.ok;
          } else {
            res.statusCode = HttpStatus.partialContent;
            res.headers.set(
              HttpHeaders.contentRangeHeader,
              'bytes 0-${length - 1}/$length',
            );
          }
          res.contentLength = length;
        }
        res.add(data);
      }

      await for (final chunk in upstream.stream) {
        final filtered = filter.feed(chunk);
        if (filtered != null) add(filtered);
      }
      final remaining = filter.finish();
      if (remaining != null) add(remaining);

      logStripped();
      await res.close();
      return;
    }

    final bytes = BytesBuilder(copy: false);
    await for (final chunk in upstream.stream) {
      final filtered = filter.feed(chunk);
      if (filtered != null) bytes.add(filtered);
    }
    final remaining = filter.finish();
    if (remaining != null) bytes.add(remaining);

    logStripped();
    await _sendBytes(req, bytes.takeBytes());
  }

  /// Sends [bytes] with a known length, honoring a single byte range.
  Future<void> _sendBytes(HttpRequest req, Uint8List bytes) async {
    final res = req.response;
    final range = _resolveRange(
      req.headers.value(HttpHeaders.rangeHeader),
      bytes.length,
    );
    res.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');

    if (range == null) {
      res.statusCode = HttpStatus.ok;
      res.contentLength = bytes.length;
      res.add(bytes);
    } else if (range.start >= bytes.length) {
      res.statusCode = HttpStatus.requestedRangeNotSatisfiable;
      res.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes */${bytes.length}',
      );
      res.contentLength = 0;
    } else {
      res.statusCode = HttpStatus.partialContent;
      res.headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes ${range.start}-${range.end}/${bytes.length}',
      );
      res.contentLength = range.end - range.start + 1;
      res.add(Uint8List.sublistView(bytes, range.start, range.end + 1));
    }
    await res.close();
  }

  /// Resolves a single `bytes=` range. Returns null when the full body should
  /// be sent; a start past [length] means the range is unsatisfiable.
  static ({int start, int end})? _resolveRange(String? header, int length) {
    final match = RegExp(
      r'^\s*bytes\s*=\s*(\d*)\s*-\s*(\d*)\s*$',
    ).firstMatch(header ?? '');
    if (match == null) return null;

    final first = int.tryParse(match[1]!);
    final last = int.tryParse(match[2]!);
    if (first == null) {
      if (last == null) return null;
      if (last == 0) return (start: length, end: length - 1);
      return (start: max(0, length - last), end: length - 1);
    }
    if (last != null && last < first) return null;
    return (start: first, end: min(last ?? length - 1, length - 1));
  }

  // ---------------------------------------------------------------------------
  // HLS manifest rewriting
  // ---------------------------------------------------------------------------

  /// Rewrites a media-segment playlist so that segment URIs point at
  /// `/segment?url=<encoded>`. EXT-X-KEY URIs are left unchanged so the
  /// player fetches decryption keys directly from the origin.
  /// EXT-X-MAP URIs and subsequent media segments are marked for fMP4 passthrough.
  /// Encrypted and EXT-X-BYTERANGE segments are marked for passthrough.
  String _rewriteStreamPlaylist(Uri upstreamUri, String originalContent) {
    bool isMaster = false;
    bool isFMP4 = false;
    bool isEncrypted = false;
    bool hasByteRange = false;

    final lines = LineSplitter.split(originalContent);
    final output = StringBuffer();

    for (final line in lines) {
      if (line.trim().isEmpty) {
        output.writeln(line);
      } else if (line.startsWith('#')) {
        if (line.startsWith('#EXT-X-STREAM-INF')) {
          isMaster = true;
        } else if (line.startsWith('#EXT-X-KEY:')) {
          final method = RegExp(
            r'(?:^|,)\s*METHOD=([^,]*)',
          ).firstMatch(line.substring(11))?.group(1)?.trim();
          isEncrypted = method != null && method != 'NONE';
        } else if (line.startsWith('#EXT-X-BYTERANGE:')) {
          hasByteRange = true;
        } else if (line.startsWith('#EXT-X-MAP:')) {
          isFMP4 = true;
          logger.fine('[HLSProxyServer] Found EXT-X-MAP, marking as fMP4');
          final attributes = line
              .substring(11)
              .replaceFirstMapped(
                RegExp(r'(^|,)(\s*URI=")([^"]*)(")'),
                (match) =>
                    '${match[1]}${match[2]}'
                    '${_segmentUrl(relativeUri(upstreamUri, match[3]!).toString(), isFMP4: true)}'
                    '${match[4]}',
              );
          output.writeln('#EXT-X-MAP:$attributes');
          continue;
        }
        output.writeln(line);
      } else {
        if (isMaster) {
          output.writeln(_streamUrl(relativeUri(upstreamUri, line).toString()));
        } else {
          output.writeln(
            _segmentUrl(
              relativeUri(upstreamUri, line).toString(),
              isFMP4: isFMP4,
              isPassthrough: isEncrypted || hasByteRange,
            ),
          );
          hasByteRange = false;
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

  String _segmentUrl(
    String upstreamUrl, {
    bool isFMP4 = false,
    bool isPassthrough = false,
  }) =>
      '$baseUrl/segment?url=${Uri.encodeComponent(upstreamUrl)}'
      '${isFMP4 ? '&format=fmp4' : ''}'
      '${isPassthrough && !isFMP4 ? '&passthrough=true' : ''}';

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
      // Rewritten playlists have different offsets than the origin.
      final upstreamReq = _upstreamRequest(
        req,
        upstreamUri,
        method: 'GET',
        forwardRange: false,
      );

      logger.fine(
        '[HLSProxyServer] Fetching $upstreamUri with headers: ${upstreamReq.headers}',
      );

      final response = await _httpClient!.send(upstreamReq);

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

  static http.Request _upstreamRequest(
    HttpRequest req,
    Uri upstreamUri, {
    required String method,
    required bool forwardRange,
  }) {
    final upstreamReq = http.Request(method, upstreamUri);
    req.headers.forEach((name, values) {
      final lowerName = name.toLowerCase();
      final isRangeHeader = lowerName == 'range' || lowerName == 'if-range';
      if (!_isHopByHopHeader(name) && (forwardRange || !isRangeHeader)) {
        upstreamReq.headers[name] = values.join(', ');
      }
    });
    return upstreamReq;
  }

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
