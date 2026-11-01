import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:strumok/video_backend/hls_proxy_server.dart';

List<int> _packets(int count) => [
  for (var i = 0; i < count; i++)
    ...(List<int>.filled(188, i + 1)
      ..[0] = 0x47
      ..[3] = 0x10 | (i % 16)),
];

void main() {
  late HttpServer upstream;
  late HLSProxyServer proxy;
  late http.Client client;
  late String playlist;
  late List<int> segment;
  late bool chunkedUpstream;
  late List<String?> upstreamRanges;

  setUp(() async {
    playlist = '#EXTM3U\nsegment.ts\n';
    segment = _packets(1);
    chunkedUpstream = false;
    upstreamRanges = [];
    upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    upstream.listen((request) async {
      final bytes = request.uri.path.endsWith('.m3u8')
          ? playlist.codeUnits
          : segment;
      final range = request.headers.value(HttpHeaders.rangeHeader);
      upstreamRanges.add(range);
      final match = RegExp(r'^bytes=(\d+)-(\d*)$').firstMatch(range ?? '');
      final res = request.response;
      if (match != null) {
        final start = int.parse(match[1]!);
        final end = match[2]!.isEmpty ? bytes.length - 1 : int.parse(match[2]!);
        res.statusCode = HttpStatus.partialContent;
        res.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/${bytes.length}',
        );
        res.add(bytes.sublist(start, end + 1));
      } else {
        if (!chunkedUpstream) res.contentLength = bytes.length;
        res.add(bytes);
      }
      await res.close();
    });
    final reservation = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    proxy = HLSProxyServer(port: reservation.port);
    await reservation.close();
    await proxy.start();
    client = http.Client();
  });

  tearDown(() async {
    client.close();
    await proxy.stop();
    await upstream.close(force: true);
  });

  Uri playlistUrl() => proxy.masterUrl(
    Uri.parse('http://127.0.0.1:${upstream.port}/playlist.m3u8'),
  );

  Future<List<Uri>> segmentUrls() async {
    final response = await client.get(playlistUrl());
    expect(response.statusCode, HttpStatus.ok);
    return response.body
        .split('\n')
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .map(Uri.parse)
        .toList();
  }

  Future<http.Response> get(Uri url, [String? range]) =>
      client.get(url, headers: {HttpHeaders.rangeHeader: ?range});

  void expectLengthFramed(http.Response response) {
    expect(response.contentLength, response.bodyBytes.length);
    expect(response.headers[HttpHeaders.transferEncodingHeader], isNull);
  }

  test('forwards clean short TS segments without losing bytes', () async {
    final response = await get((await segmentUrls()).single);
    expect(response.statusCode, HttpStatus.ok);
    expect(response.bodyBytes, segment);
    expectLengthFramed(response);
  });

  for (final chunked in [false, true]) {
    test(
      'strips junk with a known length (chunked upstream: $chunked)',
      () async {
        chunkedUpstream = chunked;
        final packets = _packets(4);
        segment = [...List<int>.filled(701, 0x99), ...packets];
        final response = await get((await segmentUrls()).single);
        expect(response.statusCode, HttpStatus.ok);
        expect(response.bodyBytes, packets);
        expectLengthFramed(response);
      },
    );
  }

  test('serves playlists with a known length and local ranges', () async {
    playlist = '#EXTM3U\n${List.generate(50, (i) => 'seg$i.ts').join('\n')}\n';
    final full = await get(playlistUrl());
    expectLengthFramed(full);

    final opening = await get(playlistUrl(), 'bytes=0-');
    expect(opening.statusCode, HttpStatus.partialContent);
    expect(opening.body, full.body);
    expect(
      opening.headers[HttpHeaders.contentRangeHeader],
      'bytes 0-${full.bodyBytes.length - 1}/${full.bodyBytes.length}',
    );
    expectLengthFramed(opening);

    final resumed = await get(playlistUrl(), 'bytes=100-');
    expect(resumed.statusCode, HttpStatus.partialContent);
    expect(resumed.bodyBytes, full.bodyBytes.sublist(100));
    expect(upstreamRanges, everyElement(isNull));
  });

  test('answers TS ranges against the filtered bytes', () async {
    final packets = _packets(4);
    segment = [...List<int>.filled(252, 0x99), ...packets];
    final url = (await segmentUrls()).single;
    final contentRange = 'bytes 0-${packets.length - 1}/${packets.length}';

    final opening = await get(url, 'bytes=0-');
    expect(opening.statusCode, HttpStatus.partialContent);
    expect(opening.bodyBytes, packets);
    expect(opening.headers[HttpHeaders.contentRangeHeader], contentRange);
    expectLengthFramed(opening);

    final resumed = await get(url, 'bytes=300-');
    expect(resumed.statusCode, HttpStatus.partialContent);
    expect(resumed.bodyBytes, packets.sublist(300));
    expect(
      resumed.headers[HttpHeaders.contentRangeHeader],
      'bytes 300-${packets.length - 1}/${packets.length}',
    );
    expectLengthFramed(resumed);

    final suffix = await get(url, 'bytes=-10');
    expect(suffix.bodyBytes, packets.sublist(packets.length - 10));

    final beyond = await get(url, 'bytes=${packets.length}-');
    expect(beyond.statusCode, HttpStatus.requestedRangeNotSatisfiable);
    expect(
      beyond.headers[HttpHeaders.contentRangeHeader],
      'bytes */${packets.length}',
    );
    expect(upstreamRanges, everyElement(isNull));
  });

  for (final method in ['AES-128', 'SAMPLE-AES']) {
    test('passes $method bytes through and tracks METHOD=NONE', () async {
      playlist =
          '''
#EXTM3U
#EXT-X-KEY:METHOD=$method,URI="key.bin"
first.ts
second.ts
#EXT-X-KEY:METHOD=NONE
clear.ts
''';
      final urls = await segmentUrls();
      expect(urls[0].queryParameters['passthrough'], 'true');
      expect(urls[1].queryParameters['passthrough'], 'true');
      expect(urls[2].queryParameters.containsKey('passthrough'), isFalse);

      segment = List<int>.filled(800, 0x99);
      for (final url in urls.take(2)) {
        final response = await get(url);
        expect(response.statusCode, HttpStatus.ok);
        expect(response.bodyBytes, segment);
        expectLengthFramed(response);
      }

      final ranged = await get(urls[0], 'bytes=100-');
      expect(ranged.statusCode, HttpStatus.partialContent);
      expect(ranged.bodyBytes, segment.sublist(100));
      expect(upstreamRanges.last, 'bytes=100-');

      segment = _packets(1);
      final clear = await get(urls[2]);
      expect(clear.statusCode, HttpStatus.ok);
      expect(clear.bodyBytes, segment);
    });
  }

  test('passes EXT-X-BYTERANGE segment ranges through to the origin', () async {
    playlist = '''
#EXTM3U
#EXT-X-BYTERANGE:376@188
media.ts
whole.ts
''';
    final urls = await segmentUrls();
    expect(urls[0].queryParameters['passthrough'], 'true');
    expect(urls[1].queryParameters.containsKey('passthrough'), isFalse);

    segment = _packets(4);
    final response = await get(urls[0], 'bytes=188-563');
    expect(response.statusCode, HttpStatus.partialContent);
    expect(response.bodyBytes, segment.sublist(188, 564));
    expect(
      response.headers[HttpHeaders.contentRangeHeader],
      'bytes 188-563/${segment.length}',
    );
    expectLengthFramed(response);
    expect(upstreamRanges.last, 'bytes=188-563');
  });

  test('preserves fMP4 init and media passthrough', () async {
    playlist = '#EXTM3U\n#EXT-X-MAP:URI="init.mp4"\nsegment.m4s\n';
    segment = List<int>.filled(800, 0x99);
    final urls = await segmentUrls();
    expect(urls.single.queryParameters['format'], 'fmp4');
    expect(urls.single.queryParameters.containsKey('passthrough'), isFalse);
    final response = await get(urls.single);
    expect(response.statusCode, HttpStatus.ok);
    expect(response.bodyBytes, segment);
    expectLengthFramed(response);

    final manifest = await get(playlistUrl());
    final initUrl = RegExp(
      r'URI="([^"]+)"',
    ).firstMatch(manifest.body)!.group(1)!;
    final init = await get(Uri.parse(initUrl));
    expect(init.statusCode, HttpStatus.ok);
    expect(init.bodyBytes, segment);
  });

  test(
    'reports invalid unencrypted TS instead of silently dropping it',
    () async {
      segment = List<int>.filled(800, 0x99);
      final response = await get((await segmentUrls()).single);
      expect(response.statusCode, HttpStatus.badGateway);
    },
  );
}
