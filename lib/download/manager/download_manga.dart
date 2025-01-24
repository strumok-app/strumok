import 'dart:io';
import 'dart:ui';

import 'package:http/http.dart';
import 'package:strumok/download/manager/models.dart';

void downloadManga(MangaDownloadRequest request, DownloadTask task, VoidCallback onDone) async {
  task.status.value = DownloadStatus.started;
  try {
    await Directory(request.folder).create(recursive: true);

    for (var i = 0; i < request.pages.length; i++) {
      if (task.status.value == DownloadStatus.canceled) {
        return;
      }

      final page = request.pages[i];

      final fileSrc = '${request.folder}/$i.jpg';
      final file = File(fileSrc);
      if (await file.exists()) {
        continue;
      }

      final httpReq = await Client().get(Uri.parse(page), headers: request.headers);

      if (httpReq.statusCode != HttpStatus.ok) {
        task.status.value = DownloadStatus.failed;
        return;
      }

      await file.writeAsBytes(httpReq.bodyBytes);

      task.progress.value = (i + 1) / request.pages.length;
    }

    task.status.value = DownloadStatus.completed;
  } catch (e) {
    task.status.value = DownloadStatus.failed;
  } finally {
    onDone();
  }
}
