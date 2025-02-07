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

enum DownloadType { video, manga, file }

abstract interface class DownloadRequest {
  String get id;
  DownloadType get type;
}

class DownloadInfo {
  final String title;
  final String image;

  DownloadInfo({required this.title, required this.image});
}

class VideoDownloadRequest implements DownloadRequest {
  @override
  final String id;

  final String url;
  final String fileSrc;
  final Map<String, String>? headers;
  final DownloadInfo info;

  @override
  final DownloadType type = DownloadType.video;

  VideoDownloadRequest({
    required this.id,
    required this.url,
    required this.fileSrc,
    required this.info,
    this.headers,
  });

  @override
  String toString() => "VideoDownloadRequest[id: $id, url: $url, fileSrc: $fileSrc]";
}

class MangaDownloadRequest implements DownloadRequest {
  @override
  final String id;

  final List<String> pages;
  final String folder;
  final Map<String, String>? headers;
  final DownloadInfo info;

  @override
  final DownloadType type = DownloadType.manga;

  MangaDownloadRequest({
    required this.id,
    required this.pages,
    required this.folder,
    required this.info,
    this.headers,
  });

  @override
  String toString() => "MangaDownloadRequest[id: $id, folder: $folder]";
}

class FileDownloadRequest implements DownloadRequest {
  final String url;
  final String fileSrc;
  final Map<String, String>? headers;

  @override
  final DownloadType type = DownloadType.file;

  @override
  final String id;

  FileDownloadRequest(this.id, this.url, this.fileSrc, {this.headers});

  @override
  String toString() => "FileDownloadRequest[id: $id, url: $url, fileSrc: $fileSrc]";
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

  void cancel() {
    status.value = DownloadStatus.canceled;
  }
}
