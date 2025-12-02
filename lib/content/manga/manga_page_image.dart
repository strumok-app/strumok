import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/download/manager/manga_pages_download_manager.dart';
import 'package:strumok/download/offline_storage.dart';
import 'package:strumok/l10n/app_localizations.dart';

class MangaPageImage extends StatefulWidget {
  final MangaPageInfo page;
  final Axis direction;

  const MangaPageImage({
    super.key,
    required this.direction,
    required this.page,
  });

  @override
  State<MangaPageImage> createState() => _MangaPageImageState();
}

class _MangaPageImageState extends State<MangaPageImage> {
  StreamSubscription<MangaPageDownloadEvent>? _downloadSubscription;

  MangaPageDownloadStatus _status = MangaPageDownloadStatus.loading;
  double _progress = 0;
  File? _file;

  @override
  void initState() {
    super.initState();
    _initialize(widget.page);
  }

  @override
  void didUpdateWidget(MangaPageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.url != widget.page.url) {
      _downloadSubscription?.cancel();
      _initialize(widget.page);
    }
  }

  void _initialize(MangaPageInfo page) async {
    if (!mounted) return;

    if (page.url.startsWith('file://')) {
      _file = File(page.url.substring(7));
      _status = MangaPageDownloadStatus.completed;
      setState(() {});
      return;
    }

    final path = _getPagePath();
    final file = File(path);
    if (await file.exists()) {
      _file = file;
      _status = MangaPageDownloadStatus.completed;
      if (mounted) setState(() {});
    } else {
      _startDownload(widget.page);
    }
  }

  void _startDownload(MangaPageInfo page) {
    final manager = MangaPagesDownloadManager();
    final path = _getPagePath();
    final file = File(path);

    final downloadStream = manager.downloadPage(
      pageUrl: page.url,
      targetFile: file,
      headers: page.source.headers,
    );

    _downloadSubscription = downloadStream.listen((event) {
      if (mounted && event.pageUrl == widget.page.url) {
        setState(() {
          _status = event.status;
          _progress = event.progress;
          _file = event.file;
        });
      }
    });
  }

  String _getPagePath() {
    var page = widget.page;
    final sourcePath = OfflineStorage().getMediaItemSourcePath(
      page.supplier,
      page.id,
      page.itemNum,
      page.source,
    );
    return "$sourcePath/${page.pageNum}.jpg";
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = switch (_status) {
      MangaPageDownloadStatus.loading => Center(
        child: CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
        ),
      ),
      MangaPageDownloadStatus.completed => Image.file(
        _file!,
        fit: BoxFit.contain,
      ),
      MangaPageDownloadStatus.failed => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.mangaReaderPageDownloadFailed),
            OutlinedButton(
              onPressed: () => _startDownload(widget.page),
              child: Text(AppLocalizations.of(context)!.errorReload),
            ),
          ],
        ),
      ),
    };

    return ManagPageAspectContainer(
      direction: widget.direction,
      child: content,
    );
  }
}
