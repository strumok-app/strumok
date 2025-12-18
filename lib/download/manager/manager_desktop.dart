import 'dart:async';
import 'dart:collection';

import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/download_manga.dart';
import 'package:strumok/download/manager/download_video.dart';
import 'package:strumok/download/manager/manager.dart';

class DownloadManagerDesktop implements DownloadManager {
  static const int maxConcurrentTasks = 3;

  final StreamController<DownloadTask> _downloadsUpdate =
      StreamController.broadcast();

  @override
  late final Stream<DownloadTask> downloadsUpdate = _downloadsUpdate.stream;
  int _runningTasks = 0;

  final Map<String, DownloadTask> _downloads = {};
  final Queue<DownloadRequest> _requests = Queue();

  static DownloadManagerDesktop? _instance;

  factory DownloadManagerDesktop() {
    return _instance ??= DownloadManagerDesktop._();
  }

  DownloadManagerDesktop._();

  @override
  DownloadTask download(DownloadRequest req) {
    if (_downloads.containsKey(req.id)) {
      return _downloads[req.id]!;
    }

    final task = DownloadTask(req);
    _requests.add(req);
    _downloads[req.id] = task;
    _downloadsUpdate.sink.add(task);

    _startExecution();

    return task;
  }

  @override
  void cancel(String id) {
    _requests.removeWhere((it) => it.id == id);
    final task = _downloads.remove(id);
    if (task != null) {
      task.cancel();
    }
  }

  void _startExecution() {
    while (_requests.isNotEmpty && _runningTasks < maxConcurrentTasks) {
      _runningTasks++;

      final request = _requests.removeFirst();
      final task = _downloads[request.id]!;

      task.start();
      _downloadsUpdate.add(task);

      void onDone(DownloadStatus status) {
        task.status.value = status;
        _downloadsUpdate.add(task);
        _runningTasks--;
        _startExecution();
      }

      if (request is FileDownloadRequest) {
        donwloadFile(request, task.updateProgress, onDone, task);
      } else if (request is VideoDownloadRequest) {
        downloadVideo(request, task.updateProgress, onDone, task);
      } else if (request is MangaDownloadRequest) {
        downloadManga(request, task.updateProgress, onDone, task);
      }
    }
  }

  @override
  DownloadTask? getTask(String id) {
    return _downloads[id];
  }

  @override
  Iterable<DownloadTask> getTasks() {
    return _downloads.values.toList();
  }

  @override
  List<DownloadTask> getDownloadTasksOfType(Set<DownloadType> types) =>
      _downloads.values.where((t) => types.contains(t.request.type)).toList();
}
