import 'dart:async';
import 'dart:io';

import 'package:strumok/download/manager/download_manga.dart';
import 'package:strumok/utils/logger.dart';

enum MangaPageDownloadStatus { loading, completed, failed }

class MangaPageDownloadEvent {
  final String pageUrl;
  final MangaPageDownloadStatus status;
  final double progress;
  final File? file;

  MangaPageDownloadEvent({
    required this.pageUrl,
    required this.status,
    this.progress = 0,
    this.file,
  });
}

class MangaPagesDownloadManager {
  static final MangaPagesDownloadManager _instance =
      MangaPagesDownloadManager._internal();

  factory MangaPagesDownloadManager() {
    return _instance;
  }

  MangaPagesDownloadManager._internal();

  final Map<String, StreamController<MangaPageDownloadEvent>>
  _downloadControllers = {};
  final Map<String, Future<void>> _ongoingDownloads = {};

  /// Start download for a page and return event stream
  Stream<MangaPageDownloadEvent> downloadPage({
    required String pageUrl,
    required File targetFile,
    required Map<String, String>? headers,
  }) {
    // Return existing stream if download is already in progress
    if (_downloadControllers.containsKey(pageUrl)) {
      return _downloadControllers[pageUrl]!.stream;
    }

    final controller = StreamController<MangaPageDownloadEvent>();
    _downloadControllers[pageUrl] = controller;

    _ongoingDownloads[pageUrl] = _performDownload(
      pageUrl: pageUrl,
      targetFile: targetFile,
      headers: headers,
      controller: controller,
    );

    return controller.stream;
  }

  Future<void> _performDownload({
    required String pageUrl,
    required File targetFile,
    required Map<String, String>? headers,
    required StreamController<MangaPageDownloadEvent> controller,
  }) async {
    try {
      // Emit loading event
      controller.add(
        MangaPageDownloadEvent(
          pageUrl: pageUrl,
          status: MangaPageDownloadStatus.loading,
        ),
      );

      await downloadPageToFile(
        pageUrl: pageUrl,
        targetFile: targetFile,
        headers: headers,
        onProgress: (progress) {
          if (!controller.isClosed) {
            controller.add(
              MangaPageDownloadEvent(
                pageUrl: pageUrl,
                status: MangaPageDownloadStatus.loading,
                progress: progress,
              ),
            );
          }
        },
      );

      // Emit completed event
      if (!controller.isClosed) {
        controller.add(
          MangaPageDownloadEvent(
            pageUrl: pageUrl,
            status: MangaPageDownloadStatus.completed,
            progress: 1.0,
            file: targetFile,
          ),
        );
      }
    } catch (e) {
      logger.warning("Failed to download page: $pageUrl, error: $e");

      // Emit failed event
      if (!controller.isClosed) {
        controller.add(
          MangaPageDownloadEvent(
            pageUrl: pageUrl,
            status: MangaPageDownloadStatus.failed,
          ),
        );
      }
    } finally {
      _downloadControllers.remove(pageUrl);
      _ongoingDownloads.remove(pageUrl);
      await controller.close();
    }
  }

  /// Cancel download by page URL
  Future<void> cancelDownload(String pageUrl) async {
    _downloadControllers[pageUrl]?.close();
    _downloadControllers.remove(pageUrl);
    _ongoingDownloads.remove(pageUrl);
  }

  /// Check if download is in progress
  bool isDownloading(String pageUrl) {
    return _ongoingDownloads.containsKey(pageUrl);
  }
}
