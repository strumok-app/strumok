import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/hls.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/utils.dart';

void downloadVideo(
  VideoDownloadRequest request,
  DownloadProgressCallback updateProgress,
  DownloadDoneCallback onDone,
  CancelToken cancelToken,
) async {
  if (await File(request.fileSrc).exists()) {
    onDone(DownloadStatus.completed);
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
    logger.info("downloading HLS master playlist for request: $request");
    final res = await Client().send(httpReq).timeout(httpTimeout);

    if (request.url.endsWith(".m3u8") ||
        res.headers['content-type'] == 'application/vnd.apple.mpegurl') {
      if (res.statusCode != HttpStatus.ok) {
        throw Exception("httpStatus: ${res.statusCode}");
      }

      final bytes = await res.stream.toBytes();
      final hls = utf8.decode(bytes);

      final master = await parseHLSManifest(uri, hls);

      logger.info("hls master playlist: $master");

      if (master.streams.isNotEmpty) {
        final sortedStreams = master.streams.sorted(
          (a, b) => b.bandwidth.compareTo(a.bandwidth),
        );
        for (int i = 0; i < sortedStreams.length; i++) {
          final selectedStream = sortedStreams[i];
          try {
            await _downloadHLSStream(
              request,
              updateProgress,
              onDone,
              cancelToken,
              selectedStream,
            );
            break;
          } catch (e) {
            logger.warning(
              "download video failed for request: $request, selectedStream: $selectedStream, error: $e",
            );
            if (i == sortedStreams.length - 1) {
              rethrow;
            }
          }
        }
      } else {
        await _downloadStreamSegments(
          request,
          updateProgress,
          onDone,
          cancelToken,
          master,
        );
      }

      onDone(DownloadStatus.completed);
    } else {
      donwloadFile(
        FileDownloadRequest(
          request.url,
          request.url,
          request.fileSrc,
          headers: request.headers,
        ),
        updateProgress,
        onDone,
        cancelToken,
      );
    }
  } catch (e) {
    logger.warning("download video failed for request: $request error: $e");
    onDone(DownloadStatus.failed);
  }
}

Future<void> _downloadHLSStream(
  VideoDownloadRequest request,
  DownloadProgressCallback updateProgress,
  DownloadDoneCallback onDone,
  CancelToken cancelToken,
  HLSStream stream,
) async {
  final req = Request('GET', stream.uri);

  if (request.headers != null) {
    req.headers.addAll(request.headers!);
  }

  logger.info("downloading HLS stream: $stream");
  final res = await Client().send(req).timeout(httpTimeout);

  if (res.statusCode != HttpStatus.ok) {
    throw Exception("stream: ${stream.uri} httpError: ${res.statusCode}");
  }

  final hls = await res.stream.bytesToString();
  final streamHls = await parseHLSManifest(stream.uri, hls);

  logger.info("hls stream playlist: $streamHls");

  await _downloadStreamSegments(
    request,
    updateProgress,
    onDone,
    cancelToken,
    streamHls,
  );
}

Future<void> _downloadStreamSegments(
  VideoDownloadRequest request,
  DownloadProgressCallback updateProgress,
  DownloadDoneCallback onDone,
  CancelToken cancelToken,
  HLSManifest manifest,
) async {
  final client = Client();

  final partialFilePath = request.fileSrc + partialExtension;
  final partialFile = File(partialFilePath);

  await partialFile.create(recursive: true);

  final sink = partialFile.openWrite(mode: FileMode.write);

  final startTs = DateTime.now();

  HLSDecryptor? decrypter;
  int bytesDownloaded = 0;

  for (var i = 0; i < manifest.segments.length; i++) {
    logger.info(
      "downloading HLS segment for request: $request, segment index: $i of ${manifest.segments.length}",
    );

    if (cancelToken.isCanceled) {
      await sink.close();
      await partialFile.delete();
      onDone(DownloadStatus.canceled);
      return;
    }

    final segment = manifest.segments[i];
    final segmentReq = Request('GET', segment.uri);

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

    if (segment.encryptionKey != null) {
      final key = segment.encryptionKey!;

      logger.info("downloading HLS key for key: $key");
      final response = await get(key.uri);

      if (response.statusCode != HttpStatus.ok) {
        throw Exception("Failed to download HLS key: ${response.statusCode}");
      }

      decrypter = HLSDecryptor(response.bodyBytes, key.iv);
    }

    if (decrypter != null) {
      var bytes = await res.stream.toBytes();
      bytes = decrypter.decrypt(bytes);

      sink.add(bytes);

      bytesDownloaded += bytes.length;
      updateProgress(
        i / manifest.segments.length,
        downloadSpeed(startTs, bytesDownloaded),
      );
    } else {
      final filter = TSJunkFilter();

      await for (var chunk in res.stream) {
        final filtered = filter.feed(chunk);
        if (filtered != null) {
          sink.add(filtered);

          bytesDownloaded += filtered.length;
          updateProgress(
            i / manifest.segments.length,
            downloadSpeed(startTs, bytesDownloaded),
          );
        }
      }

      if (!filter.syncFound) {
        throw Exception('No MPEG-TS sync found in segment: ${segment.uri}');
      } else if (filter.filteredBytes > 0) {
        logger.info(
          '[HLSProxyServer] Stripped ${filter.filteredBytes} leading junk bytes from segment: ${segment.uri}',
        );
      }
    }
  }

  await sink.close();

  await partialFile.rename(request.fileSrc);
}
