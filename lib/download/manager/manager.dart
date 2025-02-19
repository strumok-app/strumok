import 'dart:async';
import 'dart:collection';

import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/download_manga.dart';
import 'package:strumok/download/manager/download_video.dart';

import 'models.dart';

class DownloadManager {
  static const int maxConcurrentTasks = 3;

  final StreamController<DownloadTask> _downloadsUpdate = StreamController();
  late final downloadsUpdate = _downloadsUpdate.stream.asBroadcastStream();
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
    _downloadsUpdate.add(task);

    _startExecution();

    return task;
  }

  void cancel(String id) {
    _requests.removeWhere((it) => it.id == id);
    final task = _downloads.remove(id);
    if (task != null) {
      task.status.value = DownloadStatus.canceled;
      _downloadsUpdate.add(task);
    }
  }

  void _startExecution() {
    while (_requests.isNotEmpty && _runningTasks < maxConcurrentTasks) {
      _runningTasks++;

      final request = _requests.removeFirst();
      final task = _downloads[request.id]!;

      task.status.value = DownloadStatus.started;
      _downloadsUpdate.add(task);
      if (request is FileDownloadRequest) {
        donwloadFile(request, task, () => downloadDone(request));
      } else if (request is VideoDownloadRequest) {
        downloadVideo(request, task, () => downloadDone(request));
      } else if (request is MangaDownloadRequest) {
        downloadManga(request, task, () => downloadDone(request));
      }
    }
  }

  void downloadDone(DownloadRequest request) {
    _runningTasks--;
    final task = _downloads.remove(request.id);
    if (task != null) {
      _downloadsUpdate.add(task);
    }
    _startExecution();
  }

  DownloadTask? getTask(String id) {
    return _downloads[id];
  }

  Iterable<DownloadTask> getTasks() {
    return _downloads.values.toList();
  }

  List<DownloadTask> getDownloadTasksOfType(Set<DownloadType> types) =>
      _downloads.values.where((t) => types.contains(t.request.type)).toList();
}
