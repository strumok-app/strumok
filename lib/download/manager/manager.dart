import 'dart:async';
import 'package:strumok/download/manager/manager_desktop.dart';
import 'package:strumok/download/manager/manager_mobile/manager_mobile.dart';
import 'package:strumok/utils/visual.dart';

import 'models.dart';

export 'models.dart';

abstract class DownloadManager {
  static DownloadManager? _instance;

  factory DownloadManager() {
    if (_instance == null) {
      if (isDesktopDevice()) {
        _instance = DownloadManagerDesktop();
      } else {
        _instance = DownloadManagerMobile();
      }
    }
    return _instance!;
  }

  Stream<DownloadTask> get downloadsUpdate;

  DownloadTask download(DownloadRequest req);

  void cancel(String id);

  DownloadTask? getTask(String id);

  Iterable<DownloadTask> getTasks();

  List<DownloadTask> getDownloadTasksOfType(Set<DownloadType> types);
}
