import 'dart:io';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/utils.dart';

void downloadManga(
  MangaDownloadRequest request,
  DownloadTask task,
  VoidCallback onDone,
) async {
  try {
    await Directory(request.folder).create(recursive: true);

    for (var i = 0; i < request.pages.length; i++) {
      if (task.status.value == DownloadStatus.canceled) {
        await Directory(request.folder).delete(recursive: true);
        return;
      }

      final page = request.pages[i];

      final fileSrc = '${request.folder}/$i.jpg';
      final file = File(fileSrc);
      if (await file.exists()) {
        continue;
      }

      final httpReq = Request('GET', Uri.parse(page));
      httpReq.followRedirects = true;

      if (request.headers != null) {
        httpReq.headers.addAll(request.headers!);
      }

      final httpRes = await retry(
        () => Client().send(httpReq).timeout(httpTimeout),
        3,
        const Duration(seconds: 10),
      );

      if (httpRes.statusCode != HttpStatus.ok) {
        throw Exception("httpStatus: ${httpRes.statusCode}");
      }

      await file.create(recursive: true);

      final responseBytes = await httpRes.stream.toBytes();
      await file.writeAsBytes(responseBytes);

      task.progress.value = (i + 1) / request.pages.length;
      task.bytesDownloaded += responseBytes.length;
    }

    task.status.value = DownloadStatus.completed;
  } catch (e) {
    logger.w("download failed for request: $request error: $e");
    task.status.value = DownloadStatus.failed;
  } finally {
    onDone();
  }
}
