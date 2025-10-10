import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/manager/manager_mobile/download_service_handler.dart';
import 'package:strumok/download/manager/manager_mobile/events.dart';
import 'package:strumok/utils/logger.dart';

class DownloadManagerMobile implements DownloadManager {
  final StreamController<DownloadTask> _downloadsUpdate =
      StreamController.broadcast();

  @override
  late final Stream<DownloadTask> downloadsUpdate = _downloadsUpdate.stream;

  final Map<String, DownloadTask> _downloads = {};

  static DownloadManagerMobile? _instance;

  factory DownloadManagerMobile() {
    return _instance ??= DownloadManagerMobile._();
  }

  DownloadManagerMobile._() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_receiveServiceEvent);
    _initService();
  }

  @override
  DownloadTask download(DownloadRequest req) {
    if (_downloads.containsKey(req.id)) {
      return _downloads[req.id]!;
    }

    final task = DownloadTask(req);
    _downloads[req.id] = task;
    _downloadsUpdate.sink.add(task);

    _sendDownloadTaskToService(task);

    return task;
  }

  void _sendDownloadTaskToService(DownloadTask task) async {
    try {
      await _startService();

      FlutterForegroundTask.sendDataToTask([
        downloadEventRequest,
        task.request.toJson(),
      ]);
    } catch (e) {
      logger.warning(
        "Fail to send download task to foreground service: ${task.request}: $e",
      );
      task.status.value = DownloadStatus.failed;
    }
  }

  @override
  void cancel(String id) {
    FlutterForegroundTask.sendDataToTask([downloadEventCancel, id]);

    final task = _downloads.remove(id);
    if (task != null) {
      task.status.value = DownloadStatus.canceled;
      _downloadsUpdate.sink.add(task);
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

  void _receiveServiceEvent(Object data) {
    try {
      if (data is List) {
        switch (data[0]) {
          case downloadEventProgress:
            _updateDownloadTaskProgress(data);
          case downloadEventStatus:
            _updateDownloadTaskStatus(data);
          case downloadEventRestore:
            _restoreDownloadTasks(data[1]);
          default:
            logger.warning(
              "unknow event from download foregroud service: $data",
            );
        }
      }
      // nothing
    } catch (e, stackTrace) {
      logger.severe(
        "error during receive download foregroud service event: $data",
        e,
        stackTrace,
      );
    }
  }

  void _updateDownloadTaskProgress(List data) {
    final id = data[1] as String;
    final progress = data[2] as double;
    final speed = data[3] as double;

    _downloads[id]?.updateProgress(progress, speed);
  }

  void _updateDownloadTaskStatus(List data) {
    final id = data[1] as String;
    final statusIdx = data[2] as int;
    final status = DownloadStatus.values[statusIdx];

    final task = _downloads[id];
    if (task != null) {
      task.status.value = status;

      if (status.isCompleted) {
        _downloads.remove(id);
        _downloadsUpdate.sink.add(task);
      }
    }
  }

  void _restoreDownloadTasks(Object data) {
    if (data is List) {
      for (final serviceTask in data) {
        if (serviceTask is Map<String, dynamic>) {
          final request = DownloadRequest.fromJson(serviceTask["request"]);
          final statusIdx = serviceTask["status"] as int;
          final status = DownloadStatus.values[statusIdx];
          final progress = serviceTask["progress"] as double;
          final speed = serviceTask["speed"] as double;

          final task = DownloadTask(request);
          task.status.value = status;
          task.updateProgress(progress, speed);

          _downloads[request.id] = task;
        }
      }
    }

    if (_downloads.isNotEmpty) {
      _downloadsUpdate.sink.add(_downloads.values.first);
    }
  }

  Future<void> _startService() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) {
      await _requestPermissions();

      final ServiceRequestResult result =
          await FlutterForegroundTask.startService(
            serviceId: 300,
            notificationTitle: 'Starting downloads...',
            notificationText: '',
            serviceTypes: [ForegroundServiceTypes.dataSync],
            callback: startDownloadsService,
            notificationInitialRoute: '/downloads',
          );

      if (result is ServiceRequestFailure) {
        throw result.error;
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'strumok_downloads',
        channelName: 'Strumok Downloads',
        channelDescription: 'Strumok Downlods',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      FlutterForegroundTask.sendDataToTask([downloadEventRestore]);
    }
  }
}
