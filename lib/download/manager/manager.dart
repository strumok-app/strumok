import 'dart:collection';

import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/download_manga.dart';
import 'package:strumok/download/manager/download_video.dart';

import 'models.dart';

class DownloadManager {
  static const int maxConcurrentTasks = 3;

  int _runningTasks = 0;
  final Map<String, DownloadTask> _downloads = {};
  final Queue<DownloadRequest> _requests = Queue();

  static final DownloadManager _instance = DownloadManager._internal();

  factory DownloadManager() {
    return _instance;
  }

  DownloadManager._internal();

  DownloadTask download(DownloadRequest req) {
    if (_downloads.containsKey(req.id)) {
      return _downloads[req.id]!;
    }

    final task = DownloadTask(req);
    _requests.add(req);
    _downloads[req.id] = task;

    _startExecution();

    return task;
  }

  void _startExecution() {
    while (_requests.isNotEmpty && _runningTasks < maxConcurrentTasks) {
      _runningTasks++;

      final request = _requests.removeFirst();
      final task = _downloads[request.id]!;

      if (request is FileDownloadRequest) {
        donwloadFile(request, task, () => downloadDone(request));
      } else if (request is VideoDownloadRequest) {
        downloadVideo(request, task, () => downloadDone(request));
      } else if (request is MangaDownloadRequest) {
        downloadManga(request, task, () => downloadDone(request));
      } else {
        throw Exception("Unsupported request type");
      }
    }
  }

  void downloadDone(DownloadRequest request) {
    _runningTasks--;
    _downloads.remove(request.id);
    _startExecution();
  }
}
