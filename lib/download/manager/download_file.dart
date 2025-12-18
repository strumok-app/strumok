import 'dart:io';
import 'package:http/http.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/utils.dart';

import 'models.dart';

const partialExtension = ".part";
const tempExtension = ".temp";

void donwloadFile(
  FileDownloadRequest request,
  DownloadProgressCallback updateProgress,
  DownloadDoneCallback onDone,
  CancelToken cancelToken,
) async {
  try {
    final startTs = DateTime.now();
    final file = File(request.fileSrc);

    final partialFilePath = request.fileSrc + partialExtension;
    final partialFile = File(partialFilePath);

    final fileExist = await file.exists();

    if (fileExist) {
      onDone(DownloadStatus.completed);
      return;
    }

    final partialFileExist = await partialFile.exists();

    final Map<String, String> headers = {};
    if (request.headers != null) {
      headers.addAll(request.headers!);
    }

    var bytesDownloaded = 0;
    if (partialFileExist) {
      final bytesDownloaded = await partialFile.length();
      if (bytesDownloaded > 0) {
        headers[HttpHeaders.rangeHeader] = 'bytes=$bytesDownloaded-';
      }
    }

    // fileExist
    final httpReq = Request('GET', Uri.parse(request.url));
    httpReq.headers.addAll(headers);

    final res = await Client().send(httpReq).timeout(httpTimeout);

    if (res.statusCode != HttpStatus.partialContent &&
        res.statusCode != HttpStatus.ok) {
      throw Exception("httpStatus: ${res.statusCode}");
    }

    await partialFile.create(recursive: true);
    final sink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);

    await for (var chunk in res.stream) {
      if (cancelToken.isCanceled) {
        await sink.close();
        await partialFile.delete();
        onDone(DownloadStatus.canceled);
        return;
      }

      sink.add(chunk);

      bytesDownloaded += chunk.length;

      updateProgress(
        bytesDownloaded / res.contentLength!,
        downloadSpeed(startTs, bytesDownloaded),
      );
    }

    await sink.close();

    await partialFile.rename(request.fileSrc);
    onDone(DownloadStatus.completed);
  } catch (e) {
    logger.warning("download failed for request: $request error: $e");
  } finally {
    onDone(DownloadStatus.failed);
  }
}
