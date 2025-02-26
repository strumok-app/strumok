import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/download/downloading_provider.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/offline/offline_items_screen.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/visual.dart';

const downloadChannelName = "downloads";
const downloadChannelTitle = "Downloads";

class GlobalNotifications extends ConsumerStatefulWidget {
  final Widget child;
  const GlobalNotifications({super.key, required this.child});

  @override
  ConsumerState<GlobalNotifications> createState() => _GlobalNotificationsState();
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
          localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      notificationsGranted = await androidImplementation?.areNotificationsEnabled() ?? false;

      if (!notificationsGranted) {
        notificationsGranted = await androidImplementation?.requestNotificationsPermission() ?? false;
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

    if (isMobileDevice() && notificationsGranted) {
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

        final listener = listeners.remove(request.id);
        if (listener != null) {
          downloadTask.progress.removeListener(listener);
        }
      } else if (downloadTask.status.value == DownloadStatus.started) {
        final id = notificationsIds.putIfAbsent(request.id, () => nextId++);

        print("NID>>>>>> ${id}, request id: ${request.id}");
        _showDownloadingNotification(id, request, 0);

        if (!listeners.containsKey(request.id)) {
          void listener() => _showDownloadingNotification(id, request, downloadTask.progress.value);
          listeners[request.id] = listener;
          downloadTask.progress.addListener(listener);
        }
      }
    }
  }

  void _showDownloadingNotification(int id, ContentDownloadRequest request, double progress) {
    if (!notificationsIds.containsKey(request.id)) {
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        downloadChannelName,
        downloadChannelTitle,
        maxProgress: 100,
        onlyAlertOnce: true,
        autoCancel: false,
        showProgress: true,
        progress: (progress * 100).ceil(),
        ongoing: true,
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

  void _onNotificationTap(NotificationResponse details) async {
    context.navigateTo(const OfflineItemsRoute());
  }
}
