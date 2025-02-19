import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/logger.dart';

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
  final bool encrypted;
  final List<HLSStream> streams;
  final List<Uri> segments;

  HLSManifest({
    required this.uri,
    required this.encrypted,
    required this.streams,
    required this.segments,
  });
}

void downloadVideo(VideoDownloadRequest request, DownloadTask task, VoidCallback onDone) async {
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

    if (request.url.endsWith(".m3u8") || res.headers['content-type'] == 'application/vnd.apple.mpegurl') {
      final bytes = await res.stream.toBytes();
      final hls = utf8.decode(bytes);

      final master = _parseHLSManifest(uri, hls);

      if (master.encrypted) {
        throw Exception("stream encrypted");
      }

      if (master.streams.isNotEmpty) {
        final sortedStreams = master.streams.sorted((a, b) => b.bandwidth.compareTo(a.bandwidth));
        for (int i = 0; i < sortedStreams.length; i++) {
          final selectedStream = sortedStreams[i];
          try {
            await _downloadHLSStream(request, task, selectedStream, onDone);
            break;
          } catch (e) {
            logger.w("download video failed for request: $request, selectedStream: $selectedStream, error: $e");
            if (i == sortedStreams.length - 1) {
              rethrow;
            }
          }
        }
      } else {
        await _downloadStreamSegments(request, task, master, onDone);
      }
    } else {
      donwloadFile(
        FileDownloadRequest(request.url, request.url, request.fileSrc, headers: request.headers),
        task,
        onDone,
      );
    }

    task.status.value = DownloadStatus.completed;
  } catch (e) {
    logger.w("download video failed for request: $request error: $e");
    task.status.value = DownloadStatus.failed;
  } finally {
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
  final streamHls = _parseHLSManifest(stream.uri, hls);

  if (streamHls.encrypted) {
    throw Exception("stream: ${stream.uri} stream encrypted");
  }

  await _downloadStreamSegments(request, task, streamHls, onDone);
}

Future<void> _downloadStreamSegments(
  VideoDownloadRequest request,
  DownloadTask task,
  HLSManifest manifets,
  VoidCallback onDone,
) async {
  final client = Client();

  final partialFilePath = request.fileSrc + partialExtension;
  final partialFile = File(partialFilePath);

  await partialFile.create(recursive: true);

  final sink = partialFile.openWrite(mode: FileMode.write);

  for (var i = 0; i < manifets.segments.length; i++) {
    if (task.status.value == DownloadStatus.canceled) {
      await sink.close();
      await partialFile.delete();
      return;
    }

    final segment = manifets.segments[i];
    final segmentReq = Request('GET', segment);

    if (request.headers != null) {
      segmentReq.headers.addAll(request.headers!);
    }

    final res = await client.send(segmentReq).timeout(httpTimeout);

    if (res.statusCode != HttpStatus.ok) {
      await sink.close();
      throw Exception("segment: $segment httpStatus: ${res.statusCode}");
    }

    await for (var chunk in res.stream) {
      sink.add(chunk);
    }

    task.progress.value = i / manifets.segments.length;
  }

  await sink.close();

  await partialFile.rename(request.fileSrc);
}

HLSManifest _parseHLSManifest(Uri uri, String content) {
  final List<HLSStream> streams = [];
  final List<Uri> segments = [];
  bool encrypted = false;
  final lines = content.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('#')) {
      if (line.startsWith("#EXT-X-KEY:")) {
        encrypted = true;
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
          streams.add(HLSStream(
            uri: _relativeUri(uri, lines[++i]),
            bandwidth: bandwidth,
            width: width,
            height: height,
          ));
        }
      }
    } else {
      segments.add(_relativeUri(uri, line));
    }
  }

  return HLSManifest(
    uri: uri,
    encrypted: encrypted,
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
