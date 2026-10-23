import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http2/client.dart';

const _redirectStatuses = {301, 302, 303, 307, 308};

// Matches the user agent `IOClient` sends, since `Http2Client` sends none.
final _userAgent = 'Dart/${Platform.version.split(' ').first} (dart:io)';

/// `http.Client` that prefers HTTP/2 and falls back to HTTP/1.1.
///
/// HTTPS requests go through `Http2Client` (ALPN `h2`). Plain HTTP URLs and
/// hosts that cannot be reached over HTTP/2 use [IOClient] instead.
/// Redirects are followed here because `Http2Client` does not follow them.
class AppHttpClient extends http.BaseClient {
  // Shared across instances so each host is only probed once per app run.
  static final _http1Origins = <String>{};

  // ignore: experimental_member_use
  final _h2 = Http2Client();
  final _h1 = IOClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Buffered so the body can be re-sent on fallback and redirects.
    var bodyBytes = await request.finalize().toBytes();
    var method = request.method;
    var url = request.url;
    final headers = Map<String, String>.of(request.headers);
    var redirects = 0;

    while (true) {
      http.Request build() => http.Request(method, url)
        ..headers.addAll(headers)
        ..bodyBytes = bodyBytes
        ..followRedirects = false
        ..persistentConnection = request.persistentConnection;

      final res = await _sendOnce(url, build);
      final isRedirect = _redirectStatuses.contains(res.statusCode);
      final location = res.headers['location'];

      if (!request.followRedirects || !isRedirect || location == null) {
        return http.StreamedResponse(
          res.stream,
          res.statusCode,
          contentLength: res.contentLength,
          request: request,
          headers: res.headers,
          isRedirect: isRedirect,
          persistentConnection: res.persistentConnection,
          reasonPhrase: res.reasonPhrase,
        );
      }

      await res.stream.drain<void>().catchError((_) {});
      if (++redirects > request.maxRedirects) {
        throw http.ClientException('Redirect limit exceeded', request.url);
      }

      final nextUrl = url.resolve(location);
      if (res.statusCode == 303 ||
          ((res.statusCode == 301 || res.statusCode == 302) &&
              method == 'POST')) {
        method = 'GET';
        bodyBytes = Uint8List(0);
        headers.removeWhere((name, _) => name.toLowerCase() == 'content-type');
      }
      if (nextUrl.host != url.host) {
        headers.removeWhere((name, _) => name.toLowerCase() == 'authorization');
      }
      url = nextUrl;
    }
  }

  Future<http.StreamedResponse> _sendOnce(
    Uri url,
    http.Request Function() build,
  ) async {
    final origin = '${url.host}:${url.port}';
    if (url.scheme != 'https' || _http1Origins.contains(origin)) {
      return _h1.send(build());
    }

    final h2Request = build();
    h2Request.headers.putIfAbsent('user-agent', () => _userAgent);
    try {
      return await _h2.send(h2Request);
    } catch (_) {
      // `Http2Client` only reads the body after connecting, so an unread
      // request means connect, TLS or ALPN `h2` negotiation failed.
      if (h2Request.finalized) rethrow;
    }

    final res = await _h1.send(build());
    _http1Origins.add(origin);
    return res;
  }

  @override
  void close() {
    _h2.close();
    _h1.close();
  }
}

/// Creates the app's HTTP client. Close it when done.
http.Client createAppHttpClient() => AppHttpClient();

/// Shared client for short-lived requests. Never closed.
final http.Client appHttpClient = createAppHttpClient();
