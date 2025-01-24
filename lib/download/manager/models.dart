import 'dart:async';

import 'package:flutter/foundation.dart';

enum DownloadStatus {
  queued(false),
  started(false),
  completed(true),
  canceled(true),
  failed(true);

  final bool isCompleted;

  const DownloadStatus(this.isCompleted);
}

abstract interface class DownloadRequest {
  String get id;
}

class VideoDownloadRequest implements DownloadRequest {
  final String url;
  final String fileSrc;
  final Map<String, String>? headers;

  @override
  String get id => url;

  VideoDownloadRequest(this.url, this.fileSrc, {this.headers});
}

class MangaDownloadRequest implements DownloadRequest {
  final List<String> pages;
  final String folder;
  final Map<String, String>? headers;

  @override
  String get id => folder;

  MangaDownloadRequest(this.pages, this.folder, {this.headers});
}

class FileDownloadRequest implements DownloadRequest {
  final String url;
  final String fileSrc;
  final Map<String, String>? headers;

  @override
  String get id => url;

  FileDownloadRequest(this.url, this.fileSrc, {this.headers});
}

class DownloadTask {
  final DownloadRequest request;
  ValueNotifier<DownloadStatus> status = ValueNotifier(DownloadStatus.queued);
  ValueNotifier<double> progress = ValueNotifier(0);

  DownloadTask(this.request);

  Future<DownloadStatus> whenDownloadComplete({Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<DownloadStatus>();

    if (status.value.isCompleted) {
      completer.complete(status.value);
    }

    listener() {
      if (status.value.isCompleted) {
        completer.complete(status.value);
        status.removeListener(listener);
      }
    }

    status.addListener(listener);

    return completer.future.timeout(timeout);
  }
}
