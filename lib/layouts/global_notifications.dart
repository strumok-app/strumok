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

const downloadGroupKey = "app.strumok.downloads";
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

  int nextId = 1;
  bool permissionsGranted = false;
  bool permissionsRequested = true;
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
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (permissionsRequested) {
        return;
      }

      final androidImplementation = localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      permissionsRequested = true;
      try {
        permissionsGranted =
            await androidImplementation?.areNotificationsEnabled() ?? false;

        if (!permissionsGranted) {
          permissionsGranted =
              await androidImplementation?.requestNotificationsPermission() ??
              false;
        }
      } finally {
        permissionsRequested = false;
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

    if (isMobileDevice()) {
      _handleLocalNotificaionDownloadTask(context, downloadTask);
    }
  }

  void _handleLocalNotificaionDownloadTask(
    BuildContext context,
    DownloadTask downloadTask,
  ) async {
    final request = downloadTask.request;

    if (request is ContentDownloadRequest) {
      // request notification permission on download start
      if (!permissionsGranted) {
        if (downloadTask.status.value == DownloadStatus.started) {
          await _requestPermissions();
        } else {
          return;
        }
      }

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

  void _showDownloadingNotification(int id, DownloadTask taks) async {
    if (!notificationsIds.containsKey(taks.request.id)) {
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        downloadChannelName,
        downloadChannelTitle,
        maxProgress: 100,
        silent: true,
        onlyAlertOnce: true,
        autoCancel: false,
        ongoing: true,
        showProgress: true,
        progress: (taks.progress.value * 100).ceil(),
        groupKey: downloadGroupKey,
      ),
    );

    localNotificationsPlugin.show(
      id,
      downloadTaskDescription(taks),
      null,
      notificationDetails,
      payload: taks.request.id,
    );

    _showDownloadingNotificationsGroup();
  }

  void _showDownloadingNotificationsGroup() async {
    final activeNotifications = await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()!
        .getActiveNotifications();

    if (activeNotifications.where((n) => n.id == 0).isNotEmpty) {
      return;
    }

    final activeNotificationsLenth = activeNotifications.length;

    if (activeNotificationsLenth > 1) {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          downloadChannelName,
          downloadChannelTitle,
          styleInformation: InboxStyleInformation(
            activeNotifications.map((e) => e.title.toString()).toList(),
            contentTitle: "Downloads",
            summaryText: "Downloads",
          ),
          silent: true,
          setAsGroupSummary: true,
          groupKey: downloadGroupKey,
          onlyAlertOnce: true,
        ),
      );
      localNotificationsPlugin.show(0, "Downloads", null, notificationDetails);
    }
  }

  void _onNotificationTap(NotificationResponse details) async {
    widget.router.navigate(const OfflineItemsRoute());
  }
}
