import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/logger.dart';

class HLSStream {
  final String url;
  final int bandwidth;
  final int? width;
  final int? height;

  HLSStream({
    required this.url,
    required this.bandwidth,
    this.width,
    this.height,
  });
}

class HLSManifest {
  final bool encrypted;
  final List<HLSStream> streams;
  final List<String> segments;

  HLSManifest({
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
    final httpReq = Request('GET', Uri.parse(request.url));
    httpReq.headers.addAll(headers);
    final res = await Client().send(httpReq);

    if (res.statusCode != HttpStatus.ok) {
      throw Exception("httpStatus: ${res.statusCode}");
    }

    if (res.headers['content-type'] == 'application/vnd.apple.mpegurl') {
      final bytes = await res.stream.toBytes();
      final hls = utf8.decode(bytes);

      final master = _parseHLSManifest(hls);

      if (master.encrypted) {
        throw Exception("stream encrypted");
      }

      if (master.streams.isNotEmpty) {
        final selectedStream = master.streams.reduce((a, b) => a.bandwidth > b.bandwidth ? a : b);
        await _downloadHLSStream(request, task, selectedStream, onDone);
      } else {
        await _downloadStreamSegments(request, task, master.segments, onDone);
      }
    } else {
      donwloadFile(FileDownloadRequest(request.url, request.fileSrc, headers: request.headers), task, onDone);
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
  final masterUri = Uri.parse(request.url);
  final streamUri = _relativeUri(masterUri, stream.url);

  final res = await Client().get(streamUri, headers: request.headers);

  if (res.statusCode != HttpStatus.ok) {
    throw Exception("stream: $streamUri httpError: ${res.statusCode}");
  }

  final hls = res.body;
  final streamHls = _parseHLSManifest(hls);

  if (streamHls.encrypted) {
    throw Exception("stream: $streamUri stream encrypted");
  }

  await _downloadStreamSegments(request, task, streamHls.segments, onDone);
}

Uri _relativeUri(Uri masterUri, String url) {
  final streamUri = Uri.parse(url);
  if (streamUri.isAbsolute) {
    return streamUri;
  }

  return masterUri.resolve(url);
}

Future<void> _downloadStreamSegments(
  VideoDownloadRequest request,
  DownloadTask task,
  List<String> segments,
  VoidCallback onDone,
) async {
  final masterUri = Uri.parse(request.url);
  final client = Client();

  final partialFilePath = request.fileSrc + partialExtension;
  final partialFile = File(partialFilePath);

  final sink = partialFile.openWrite(mode: FileMode.write);

  for (var i = 0; i < segments.length; i++) {
    if (task.status.value == DownloadStatus.canceled) {
      sink.close();
      await partialFile.delete();
      return;
    }

    final segment = segments[i];
    final segmentUri = _relativeUri(masterUri, segment);
    final segmentReq = Request('GET', segmentUri);
    if (request.headers != null) {
      segmentReq.headers.addAll(request.headers!);
    }

    final res = await client.send(segmentReq);

    if (res.statusCode != HttpStatus.ok) {
      throw Exception("segment: $segment httpStatus: ${res.statusCode}");
    }

    await for (var chunk in res.stream) {
      sink.add(chunk);
    }

    task.progress.value = i / segments.length;
  }

  await sink.close();

  await partialFile.rename(request.fileSrc);
}

HLSManifest _parseHLSManifest(String content) {
  final List<HLSStream> streams = [];
  final List<String> segments = [];
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
            url: lines[++i],
            bandwidth: bandwidth,
            width: width,
            height: height,
          ));
        }
      }
    } else {
      segments.add(line);
    }
  }

  return HLSManifest(encrypted: encrypted, streams: streams, segments: segments);
}
