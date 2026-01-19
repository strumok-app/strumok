import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:strumok/download/manager/download_file.dart';
import 'package:strumok/download/manager/download_manga.dart';
import 'package:strumok/download/manager/download_video.dart';
import 'package:strumok/download/manager/manager_mobile/events.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/text.dart';

@pragma('vm:entry-point')
void startDownloadsService() {
  FlutterForegroundTask.setTaskHandler(DownloadsServiceHandler());
}

class DownloadsServiceTask implements CancelToken {
  final DownloadRequest request;

  DownloadStatus status = DownloadStatus.queued;

  double progress = 0;
  double speed = 0;

  DownloadsServiceTask(this.request);

  void setStatus(DownloadStatus status) {
    this.status = status;

    FlutterForegroundTask.sendDataToMain([
      downloadEventStatus,
      request.id,
      status.index,
    ]);
  }

  @override
  bool get isCanceled => status == DownloadStatus.canceled;

  @override
  void cancel() {
    status = DownloadStatus.canceled;
  }

  Map<String, dynamic> toJson() => {
    "request": request.toJson(),
    "status": status.index,
    "progress": progress,
    "speed": speed,
  };
}

class DownloadsServiceHandler extends TaskHandler {
  static const int maxConcurrentTasks = 3;

  final Map<String, DownloadsServiceTask> _downloads = {};
  final Queue<DownloadRequest> _requests = Queue();
  int _runningTasks = 0;

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // cleanup?
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _updateNotification();
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // nothing here
  }

  @override
  void onReceiveData(Object data) {
    try {
      if (data is List) {
        switch (data[0]) {
          case downloadEventRequest:
            _addRequest(data[1]);
          case downloadEventCancel:
            _cancelDownload(data[1]);
          case downloadEventRestore:
            _sendCurrentRequestsList();
          default:
            logger.warning(
              "[download foregroud service] unknow download service event: $data",
            );
        }
      }
    } catch (e, stackTrace) {
      logger.severe(
        "[downlod foreground service] error processing event: $data",
        e,
        stackTrace,
      );
    }
  }

  void _addRequest(Object data) {
    if (data is Map<String, dynamic>) {
      final request = DownloadRequest.fromJson(data);

      if (_downloads.containsKey(request.id)) {
        return;
      }

      final task = DownloadsServiceTask(request);
      _downloads[request.id] = task;
      _requests.add(request);

      _startExecution();
    }
  }

  void _startExecution() {
    while (_requests.isNotEmpty && _runningTasks < maxConcurrentTasks) {
      _runningTasks++;

      final request = _requests.removeFirst();
      final task = _downloads[request.id]!;

      task.setStatus(DownloadStatus.started);

      void onDone(DownloadStatus status) {
        _runningTasks--;
        task.setStatus(status);
        _downloads.remove(request.id);
        _startExecution();

        if (_downloads.isEmpty) {
          FlutterForegroundTask.stopService();
        }
      }

      void updateProgress(double progress, double speed) {
        task.progress = progress;
        task.speed = speed;

        FlutterForegroundTask.sendDataToMain([
          downloadEventProgress,
          request.id,
          progress,
          speed,
        ]);
      }

      if (request is FileDownloadRequest) {
        donwloadFile(request, updateProgress, onDone, task);
      } else if (request is VideoDownloadRequest) {
        downloadVideo(request, updateProgress, onDone, task);
      } else if (request is MangaDownloadRequest) {
        downloadManga(request, updateProgress, onDone, task);
      }
    }
  }

  void _cancelDownload(Object id) {
    if (id is String) {
      final task = _downloads.remove(id);
      if (task != null) {
        task.cancel();
      }

      if (_downloads.isEmpty) {
        FlutterForegroundTask.stopService();
      }
    }
  }

  void _sendCurrentRequestsList() {
    final currentRequests = _downloads.values
        .map((task) => task.toJson())
        .toList();

    FlutterForegroundTask.sendDataToMain([
      downloadEventRestore,
      currentRequests,
    ]);
  }

  void _updateNotification() async {
    final total = _downloads.length;
    final notificationTitle = "Donloading: $_runningTasks/$total";

    final notificationText = _downloads.values
        .where((task) => task.status == DownloadStatus.started)
        .mapIndexed((idx, task) {
          final speed = formatBytes(task.speed.floor());
          final progress = (task.progress * 100.0).floor();
          String result = "$progress% ($speed/s)";

          if (task.request is ContentDownloadRequest) {
            final cdr = task.request as ContentDownloadRequest;
            result = "${cdr.info.title} $result";
          } else {
            result = "${idx + 1}. $result";
          }

          return result;
        })
        .join("\n");

    FlutterForegroundTask.updateService(
      notificationTitle: notificationTitle,
      notificationText: notificationText,
    );
  }
}
