import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/download/downloading_provider.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/utils/visual.dart';

const downloadChannelName = "downloads";
const downloadChannelTitle = "Downloads";

class GlobalNotifications extends ConsumerStatefulWidget {
  final Widget child;
  final AppRouter router;

  const GlobalNotifications({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  ConsumerState<GlobalNotifications> createState() =>
      _GlobalNotificationsState();
}

class _GlobalNotificationsState extends ConsumerState<GlobalNotifications> {
  final localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int nextId = 0;
  bool notificationsGranted = false;
  final Map<String, int> notificationsIds = {};
  final Map<String, VoidCallback> listeners = {};

  @override
  void initState() {
    super.initState();

    if (isMobileDevice()) {
      final initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher_foreground'),
      );

      localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      notificationsGranted =
          await androidImplementation?.areNotificationsEnabled() ?? false;

      if (!notificationsGranted) {
        notificationsGranted =
            await androidImplementation?.requestNotificationsPermission() ??
            false;
      }
    }
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
              content: Text(
                AppLocalizations.of(
                  context,
                )!.downloadsFailed(request.info.title),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    if (isMobileDevice() && notificationsGranted) {
      _handleLocalNotificaionDownloadTask(context, downloadTask);
    }
  }

  void _handleLocalNotificaionDownloadTask(
    BuildContext context,
    DownloadTask downloadTask,
  ) {
    final request = downloadTask.request;
    if (request is ContentDownloadRequest) {
      if (downloadTask.status.value.isCompleted) {
        final id = notificationsIds.remove(request.id);
        if (id != null) {
          localNotificationsPlugin.cancel(id);
        }

        final listener = listeners.remove(request.id);
        if (listener != null) {
          downloadTask.progress.removeListener(listener);
        }
      } else if (downloadTask.status.value == DownloadStatus.started) {
        final id = notificationsIds.putIfAbsent(request.id, () => nextId++);

        _showDownloadingNotification(id, downloadTask);

        if (!listeners.containsKey(request.id)) {
          void listener() => _showDownloadingNotification(id, downloadTask);
          listeners[request.id] = listener;
          downloadTask.progress.addListener(listener);
        }
      }
    }
  }

  void _showDownloadingNotification(int id, DownloadTask taks) {
    if (!notificationsIds.containsKey(taks.request.id)) {
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        downloadChannelName,
        downloadChannelTitle,
        maxProgress: 100,
        onlyAlertOnce: true,
        autoCancel: false,
        ongoing: true,
        showProgress: true,
        progress: (taks.progress.value * 100).ceil(),
        groupKey: downloadChannelName,
      ),
    );

    localNotificationsPlugin.show(
      id,
      downloadTaskDescription(taks),
      null,
      notificationDetails,
      payload: taks.request.id,
    );
  }

  void _onNotificationTap(NotificationResponse details) async {
    widget.router.navigate(const OfflineItemsRoute());
  }
}
