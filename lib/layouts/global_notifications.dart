import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/download/downloading_provider.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/visual.dart';

const channelName = "downloads";
const channelTitle = "Downloads";

class GlobalNotifications extends ConsumerStatefulWidget {
  final Widget child;
  const GlobalNotifications({super.key, required this.child});

  @override
  ConsumerState<GlobalNotifications> createState() => _GlobalNotificationsState();
}

class _GlobalNotificationsState extends ConsumerState<GlobalNotifications> {
  final localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int nextId = 0;
  final Map<String, int> notificationsIds = {};
  final Map<String, VoidCallback> listeners = {};

  @override
  void initState() {
    super.initState();

    if (isMobileDevice()) {
      final initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher_foreground'),
      );

      localNotificationsPlugin.initialize(initializationSettings);

      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final granted = await androidImplementation?.areNotificationsEnabled() ?? false;

      if (!granted) {
        await androidImplementation?.requestNotificationsPermission();
      }
    }
  }

  @override
  void dispose() {
    if (isMobileDevice()) {
      localNotificationsPlugin.cancelAll();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(downloadsUpdateStreamProvider, (_, next) {
      final downloadTask = next.valueOrNull;
      if (downloadTask != null) {
        _handleDownloadTask(context, downloadTask);
      }
    });

    return widget.child;
  }

  void _handleDownloadTask(BuildContext context, DownloadTask downloadTask) {
    if (downloadTask.status.value == DownloadStatus.failed) {
      if (context.mounted) {
        final request = downloadTask.request;
        if (request is ContentDownloadRequest) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.downloadsFailed(request.info.title)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    if (isMobileDevice()) {
      _handleLocalNotificaionDownloadTask(context, downloadTask);
    }
  }

  void _handleLocalNotificaionDownloadTask(BuildContext context, DownloadTask downloadTask) {
    final request = downloadTask.request;
    if (request is ContentDownloadRequest) {
      if (downloadTask.status.value.isCompleted) {
        final id = notificationsIds.remove(request.id);
        if (id != null) {
          localNotificationsPlugin.cancel(id);
        }

        final listener = listeners[request.id];
        if (listener != null) {
          downloadTask.progress.removeListener(listener);
        }
      } else {
        final id = notificationsIds.putIfAbsent(request.id, () => nextId++);

        _showNotification(id, request, 0);

        if (downloadTask.status.value == DownloadStatus.started) {
          void listener() => _showNotification(id, request, downloadTask.progress.value);
          listeners[request.id] = listener;
          downloadTask.progress.addListener(listener);
        }
      }
    }
  }

  void _showNotification(int id, ContentDownloadRequest request, double progress) {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelName,
        channelTitle,
        maxProgress: 100,
        onlyAlertOnce: true,
        autoCancel: false,
        showProgress: true,
        progress: (progress * 100).ceil(),
      ),
    );

    localNotificationsPlugin.show(
      id,
      request.info.title,
      null,
      notificationDetails,
      payload: request.id,
    );
  }
}
