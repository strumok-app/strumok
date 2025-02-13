import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart';
import 'package:strumok/utils/logger.dart';

import 'models.dart';

const partialExtension = ".part";
const tempExtension = ".temp";

void donwloadFile(FileDownloadRequest request, DownloadTask task, VoidCallback onDone) async {
  try {
    final file = File(request.fileSrc);

    final partialFilePath = request.fileSrc + partialExtension;
    final partialFile = File(partialFilePath);

    final fileExist = await file.exists();

    if (fileExist) {
      task.status.value = DownloadStatus.completed;
      onDone();
      return;
    }

    final partialFileExist = await partialFile.exists();

    final Map<String, String> headers = {};
    if (request.headers != null) {
      headers.addAll(request.headers!);
    }

    var bytesDownloaded = 0;
    if (partialFileExist) {
      headers[HttpHeaders.rangeHeader] = 'bytes=${await partialFile.length()}-';
      bytesDownloaded = await partialFile.length();
    }

    // fileExist
    final httpReq = Request('GET', Uri.parse(request.url));
    httpReq.headers.addAll(headers);

    final res = await Client().send(httpReq).timeout(httpTimeout);

    if (res.statusCode != HttpStatus.partialContent && res.statusCode != HttpStatus.ok) {
      throw Exception("httpStatus: ${res.statusCode}");
    }

    await partialFile.create(recursive: true);
    final sink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);

    await for (var chunk in res.stream) {
      if (task.status.value == DownloadStatus.canceled) {
        sink.close();
        await partialFile.delete();
        return;
      }

      sink.add(chunk);
      task.progress.value = bytesDownloaded / res.contentLength!.toDouble();
    }

    sink.close();

    await partialFile.rename(request.fileSrc);
    task.status.value = DownloadStatus.completed;
    onDone();
  } catch (e) {
    logger.w("download failed for request: $request error: $e");
    task.status.value = DownloadStatus.failed;
  } finally {
    onDone();
  }
}
