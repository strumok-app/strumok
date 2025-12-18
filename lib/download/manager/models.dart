import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:strumok/utils/text.dart';

part 'models.g.dart';

const httpTimeout = Duration(seconds: 30);

enum DownloadStatus {
  queued(false),
  started(false),
  completed(true),
  canceled(true),
  failed(true);

  final bool isCompleted;

  const DownloadStatus(this.isCompleted);
}

@JsonEnum()
enum DownloadType { video, manga, file }

abstract interface class DownloadRequest {
  String get id;
  DownloadType get type;
  Map<String, dynamic> toJson();

  static DownloadRequest fromJson(Map<String, dynamic> json) {
    return switch (json["type"]) {
      "video" => VideoDownloadRequest.fromJson(json),
      "manga" => MangaDownloadRequest.fromJson(json),
      "file" => FileDownloadRequest.fromJson(json),
      _ => throw Exception("Unknown DownloadRequest type"),
    };
  }
}

abstract interface class ContentDownloadRequest extends DownloadRequest {
  DownloadInfo get info;
}

@JsonSerializable()
class DownloadInfo {
  final String title;
  final String image;

  DownloadInfo({required this.title, required this.image});

  factory DownloadInfo.fromJson(Map<String, dynamic> json) =>
      _$DownloadInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class VideoDownloadRequest extends Equatable
    implements DownloadRequest, ContentDownloadRequest {
  @override
  final String id;

  final String url;
  final String fileSrc;
  final Map<String, String>? headers;

  @override
  final DownloadInfo info;

  @JsonKey(includeToJson: true)
  @override
  final DownloadType type = DownloadType.video;

  const VideoDownloadRequest({
    required this.id,
    required this.url,
    required this.fileSrc,
    required this.info,
    this.headers,
  });

  @override
  String toString() =>
      "VideoDownloadRequest[id: $id, url: $url, fileSrc: $fileSrc]";

  factory VideoDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$VideoDownloadRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoDownloadRequestToJson(this);

  @override
  List<Object?> get props => [id, type];
}

@JsonSerializable(explicitToJson: true)
class MangaDownloadRequest extends Equatable
    implements DownloadRequest, ContentDownloadRequest {
  @override
  final String id;

  final List<String> pages;
  final String folder;
  final Map<String, String>? headers;
  @override
  final DownloadInfo info;

  @JsonKey(includeToJson: true)
  @override
  final DownloadType type = DownloadType.manga;

  const MangaDownloadRequest({
    required this.id,
    required this.pages,
    required this.folder,
    required this.info,
    this.headers,
  });

  @override
  String toString() => "MangaDownloadRequest[id: $id, folder: $folder]";

  factory MangaDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$MangaDownloadRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MangaDownloadRequestToJson(this);

  @override
  List<Object?> get props => [id, type];
}

@JsonSerializable()
class FileDownloadRequest extends Equatable implements DownloadRequest {
  final String url;
  final String fileSrc;
  final Map<String, String>? headers;

  @JsonKey(includeToJson: true)
  @override
  final DownloadType type = DownloadType.file;

  @override
  final String id;

  const FileDownloadRequest(this.id, this.url, this.fileSrc, {this.headers});

  @override
  String toString() =>
      "FileDownloadRequest[id: $id, url: $url, fileSrc: $fileSrc]";

  factory FileDownloadRequest.fromJson(Map<String, dynamic> json) =>
      _$FileDownloadRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FileDownloadRequestToJson(this);

  @override
  List<Object?> get props => [id, type];
}

abstract interface class CancelToken {
  bool get isCanceled;
  void cancel();
}

class DownloadTask implements CancelToken {
  final DownloadRequest request;

  ValueNotifier<DownloadStatus> status = ValueNotifier(DownloadStatus.queued);
  ValueNotifier<double> progress = ValueNotifier(0);

  double? _speed;

  DownloadTask(this.request);

  void updateProgress(double progress, double speed) {
    this.progress.value = progress;

    _speed = speed;
  }

  Future<DownloadStatus> whenDownloadComplete({
    Duration timeout = const Duration(hours: 2),
  }) async {
    var completer = Completer<DownloadStatus>();

    if (status.value.isCompleted) {
      completer.complete(status.value);
    }

    void listener() {
      if (status.value.isCompleted) {
        completer.complete(status.value);
        status.removeListener(listener);
      }
    }

    status.addListener(listener);

    return completer.future.timeout(timeout);
  }

  void start() {
    status.value = DownloadStatus.started;
  }

  @override
  bool get isCanceled => status.value == DownloadStatus.canceled;

  @override
  void cancel() {
    status.value = DownloadStatus.canceled;
  }

  String? speed() {
    if (_speed != null) {
      return formatBytes(_speed!.floor());
    }

    return null;
  }
}

typedef DownloadProgressCallback = void Function(double progress, double bytes);
typedef DownloadDoneCallback = void Function(DownloadStatus state);
