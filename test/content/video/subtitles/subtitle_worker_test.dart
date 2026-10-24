import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:strumok/content/video/subtitle_worker.dart';

void main() {
  late HttpServer server;
  late SubtitleWorker worker;
  final receivedHeaders = <String, String?>{};

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      receivedHeaders['referer'] = request.headers.value('referer');
      switch (request.uri.path) {
        case '/subs':
          // Windows-1251 SRT served without any extension in the URL.
          request.response.add([
            ...ascii.encode('1\r\n00:00:01,000 --> 00:00:02,000\r\n'),
            0xCF, 0xF0, 0xE8, 0xE2, 0xB3, 0xF2, 0x20, 0x26, 0x61, 0x6D, //
            0x70, 0x3B, 0x20, 0xF1, 0xE2, 0xB3, 0xF2, 0xE5,
          ]);
        case '/missing':
          request.response.statusCode = HttpStatus.notFound;
          request.response.write('not found');
        default:
          request.response.statusCode = HttpStatus.badRequest;
      }
      await request.response.close();
    });

    worker = SubtitleWorker();
  });

  tearDownAll(() async {
    worker.dispose();
    await server.close(force: true);
  });

  String url(String path) => 'http://127.0.0.1:${server.port}$path';

  test('downloads, decodes and parses subtitles in the isolate', () async {
    final track = await worker.parseSubtitle(url('/subs'), {
      'Referer': 'https://example.com',
    });

    expect(track.cues.single.text, 'Привіт & світе');
    expect(receivedHeaders['referer'], 'https://example.com');
  });

  test('reports HTTP errors', () async {
    expect(
      () => worker.parseSubtitle(url('/missing'), null),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('HTTP 404'),
        ),
      ),
    );
  });

  test('reads local file URIs', () async {
    final dir = await Directory.systemTemp.createTemp('subs_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/episode.vtt');
    await file.writeAsString(
      'WEBVTT\n\n00:01.000 --> 00:02.000\n<i>Local</i>\n',
    );

    final track = await worker.parseSubtitle(file.uri.toString(), null);

    expect(track.cues.single.text, 'Local');
  });
}
