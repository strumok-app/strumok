import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/utils.dart';

class HLSStream {
  final Uri uri;
  final int bandwidth;
  final int? width;
  final int? height;

  HLSStream({
    required this.uri,
    required this.bandwidth,
    this.width,
    this.height,
  });
}

class HLSManifest {
  final Uri uri;
  final Uint8List? encryptionKey;
  final List<HLSStream> streams;
  final List<Uri> segments;

  HLSManifest({
    required this.uri,
    this.encryptionKey,
    required this.streams,
    required this.segments,
  });
}

void downloadVideo(
  VideoDownloadRequest request,
  DownloadTask task,
  VoidCallback onDone,
) async {
  task.status.value = DownloadStatus.started;

  if (await File(request.fileSrc).exists()) {
    task.status.value = DownloadStatus.completed;
    onDone();
    return;
  }

  final Map<String, String> headers = {};
  if (request.headers != null) {
    headers.addAll(request.headers!);
  }

  try {
    final uri = Uri.parse(request.url);
    final httpReq = Request('GET', uri);

    httpReq.headers.addAll(headers);
    final res = await Client().send(httpReq).timeout(httpTimeout);

    if (res.statusCode != HttpStatus.ok) {
      throw Exception("httpStatus: ${res.statusCode}");
    }

    if (request.url.endsWith(".m3u8") ||
        res.headers['content-type'] == 'application/vnd.apple.mpegurl') {
      final bytes = await res.stream.toBytes();
      final hls = utf8.decode(bytes);

      final master = await _parseHLSManifest(uri, hls);

      if (master.streams.isNotEmpty) {
        final sortedStreams = master.streams.sorted(
          (a, b) => b.bandwidth.compareTo(a.bandwidth),
        );
        for (int i = 0; i < sortedStreams.length; i++) {
          final selectedStream = sortedStreams[i];
          try {
            await _downloadHLSStream(request, task, selectedStream, onDone);
            break;
          } catch (e) {
            logger.w(
              "download video failed for request: $request, selectedStream: $selectedStream, error: $e",
            );
            if (i == sortedStreams.length - 1) {
              rethrow;
            }
          }
        }
      } else {
        await _downloadStreamSegments(request, task, master, onDone);
      }

      task.status.value = DownloadStatus.completed;
      onDone();
    } else {
      donwloadFile(
        FileDownloadRequest(
          request.url,
          request.url,
          request.fileSrc,
          headers: request.headers,
        ),
        task,
        onDone,
      );
    }
  } catch (e) {
    logger.w("download video failed for request: $request error: $e");
    task.status.value = DownloadStatus.failed;
    onDone();
  }
}

Future<void> _downloadHLSStream(
  VideoDownloadRequest request,
  DownloadTask task,
  HLSStream stream,
  VoidCallback onDone,
) async {
  final req = Request('GET', stream.uri);

  if (request.headers != null) {
    req.headers.addAll(request.headers!);
  }

  final res = await Client().send(req).timeout(httpTimeout);

  if (res.statusCode != HttpStatus.ok) {
    throw Exception("stream: ${stream.uri} httpError: ${res.statusCode}");
  }

  final hls = await res.stream.bytesToString();
  final streamHls = await _parseHLSManifest(stream.uri, hls);

  await _downloadStreamSegments(request, task, streamHls, onDone);
}

Future<void> _downloadStreamSegments(
  VideoDownloadRequest request,
  DownloadTask task,
  HLSManifest manifet,
  VoidCallback onDone,
) async {
  final decrypter =
      manifet.encryptionKey != null ? _Decryptor(manifet.encryptionKey!) : null;

  final client = Client();

  final partialFilePath = request.fileSrc + partialExtension;
  final partialFile = File(partialFilePath);

  await partialFile.create(recursive: true);

  final sink = partialFile.openWrite(mode: FileMode.write);

  for (var i = 0; i < manifet.segments.length; i++) {
    if (task.status.value == DownloadStatus.canceled) {
      await sink.close();
      await partialFile.delete();
      return;
    }

    final segment = manifet.segments[i];
    final segmentReq = Request('GET', segment);

    if (request.headers != null) {
      segmentReq.headers.addAll(request.headers!);
    }

    final res = await retry(
      () => client.send(segmentReq).timeout(httpTimeout),
      3,
      const Duration(seconds: 10),
    );

    if (res.statusCode != HttpStatus.ok) {
      await sink.close();
      throw Exception("segment: $segment httpStatus: ${res.statusCode}");
    }

    if (decrypter != null) {
      var bytes = await res.stream.toBytes();
      bytes = decrypter.decrypt(bytes);

      sink.add(bytes);

      task.progress.value = i / manifet.segments.length;
      task.bytesDownloaded += bytes.length;
    } else {
      await for (var chunk in res.stream) {
        sink.add(chunk);

        task.progress.value = i / manifet.segments.length;
        task.bytesDownloaded += chunk.length;
      }
    }
  }

  await sink.close();

  await partialFile.rename(request.fileSrc);
}

Future<HLSManifest> _parseHLSManifest(Uri uri, String content) async {
  final List<HLSStream> streams = [];
  final List<Uri> segments = [];
  Uint8List? encryptionKey;
  final lines = content.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('#')) {
      if (line.startsWith("#EXT-X-KEY:")) {
        encryptionKey = await _parseHLSKey(line);
      } else if (line.startsWith("#EXT-X-STREAM-INF:")) {
        final attrs = line.split(':').last.split(',');
        int? bandwidth;
        int? width;
        int? height;

        for (final attr in attrs) {
          final parts = attr.split('=');
          if (parts[0] == 'BANDWIDTH') {
            bandwidth = int.parse(parts[1]);
          } else if (parts[0] == 'RESOLUTION') {
            final res = parts[1].split('x');
            width = int.parse(res[0]);
            height = int.parse(res[1]);
          }
        }

        if (bandwidth != null && i < lines.length - 1) {
          streams.add(
            HLSStream(
              uri: _relativeUri(uri, lines[++i]),
              bandwidth: bandwidth,
              width: width,
              height: height,
            ),
          );
        }
      }
    } else {
      segments.add(_relativeUri(uri, line));
    }
  }

  return HLSManifest(
    uri: uri,
    encryptionKey: encryptionKey,
    streams: streams,
    segments: segments,
  );
}

Uri _relativeUri(Uri masterUri, String url) {
  final streamUri = Uri.parse(url);
  if (streamUri.isAbsolute) {
    return streamUri;
  }

  return masterUri.resolve(url);
}

Future<Uint8List?> _parseHLSKey(String keyLine) async {
  if (!keyLine.startsWith('#EXT-X-KEY:')) return null;

  final attrs = keyLine.substring(11).split(',');
  String? method;
  String? uri;

  for (final attr in attrs) {
    final parts = attr.split('=');
    if (parts.length != 2) continue;

    final key = parts[0].trim();
    final value = parts[1].replaceAll('"', '').trim();

    if (key == 'METHOD') {
      method = value;
    } else if (key == 'URI') {
      uri = value;
    }
  }

  if (method != 'AES-128' || uri == null) return null;

  try {
    final response = await get(Uri.parse(uri));
    if (response.statusCode == HttpStatus.ok) {
      return response.bodyBytes;
    }
  } catch (e) {
    logger.w('Failed to download HLS key: $e');
  }

  return null;
}

class _Decryptor {
  final BlockCipher cipher;

  _Decryptor(Uint8List key)
    : cipher = PaddedBlockCipher("AES/CBC/PKCS7")..init(
        false,
        PaddedBlockCipherParameters(
          ParametersWithIV(KeyParameter(key), Uint8List(16)),
          null,
        ),
      );

  Uint8List decrypt(Uint8List data) {
    return cipher.process(data);
  }
}
