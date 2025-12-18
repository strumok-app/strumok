import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/utils.dart';

void downloadManga(
  MangaDownloadRequest request,
  DownloadProgressCallback updateProgress,
  DownloadDoneCallback onDone,
  CancelToken cancelToken,
) async {
  try {
    await Directory(request.folder).create(recursive: true);

    final startTs = DateTime.now();
    var bytesDownloaded = 0;
    for (var i = 0; i < request.pages.length; i++) {
      if (cancelToken.isCanceled) {
        onDone(DownloadStatus.canceled);
        return;
      }

      final page = request.pages[i];
      final targetFile = File('${request.folder}/$i.jpg');

      // Skip if file already exists
      if (await targetFile.exists()) {
        continue;
      }

      await downloadPageToFile(
        pageUrl: page,
        targetFile: targetFile,
        headers: request.headers,
      );

      bytesDownloaded += await targetFile.length();
      updateProgress(
        (i + 1) / request.pages.length,
        downloadSpeed(startTs, bytesDownloaded),
      );
    }

    final completeFile = File('${request.folder}/complete');
    await completeFile.create(recursive: true);
    await completeFile.writeAsString(
      jsonEncode({
        'pages': request.pages.length,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    onDone(DownloadStatus.completed);
  } catch (e) {
    logger.warning("download failed for request: $request error: $e");
    onDone(DownloadStatus.failed);
  }
}

Future<void> downloadPageToFile({
  required String pageUrl,
  required File targetFile,
  required Map<String, String>? headers,
  void Function(double)? onProgress,
}) async {
  final tempFile = File(
    '${targetFile.path}.tmp.${DateTime.now().millisecondsSinceEpoch}',
  );

  try {
    final httpReq = Request('GET', Uri.parse(pageUrl));
    httpReq.followRedirects = true;

    if (headers != null) {
      httpReq.headers.addAll(headers);
    }

    final httpRes = await retry(
      () => Client().send(httpReq).timeout(httpTimeout),
      3,
      const Duration(seconds: 10),
    );

    if (httpRes.statusCode != HttpStatus.ok) {
      throw Exception("httpStatus: ${httpRes.statusCode}");
    }

    await tempFile.create(recursive: true);

    final contentLength = httpRes.contentLength ?? 0;
    var bytesReceived = 0;

    final bytes = <int>[];
    await for (final chunk in httpRes.stream) {
      bytes.addAll(chunk);
      bytesReceived += chunk.length;

      if (onProgress != null && contentLength > 0) {
        onProgress(bytesReceived / contentLength);
      }
    }

    await tempFile.writeAsBytes(bytes);

    // Move temp file to target only if target doesn't exist
    if (!await targetFile.exists()) {
      await tempFile.rename(targetFile.path);
    } else {
      await tempFile.delete();
    }
  } catch (e) {
    // Clean up temp file on error
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
    rethrow;
  }
}
