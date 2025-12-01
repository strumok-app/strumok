import 'dart:io';

import 'package:flutter/material.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
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
  _Status _status = _Status.loading;
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

    _initialize(widget.page);
  }

  void _initialize(MangaPageInfo page) async {
    if (!mounted) return;

    if (page.url.startsWith('file://')) {
      _file = File(page.url.substring(7));
      _status = _Status.downloaded;
      setState(() {});
      return;
    }

    final path = _getPagePath();
    final file = File(path);
    if (await file.exists()) {
      _file = file;
      _status = _Status.downloaded;
      if (mounted) setState(() {});
    } else {
      _startDownload(page.url);
    }
  }

  void _startDownload(String url) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _status = _Status.loading;
      _progress = 0;
    });

    _Status status;
    File? file;

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final path = _getPagePath();
        file = File(path);
        await file.create(recursive: true);
        final sink = file.openWrite();

        int total = response.contentLength;
        int received = 0;

        await for (var chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) {
            if (mounted && url == widget.page.url) {
              setState(() {
                _progress = received / total;
              });
            }
          }
        }

        await sink.close();
        status = _Status.downloaded;
      } else {
        status = _Status.error;
      }
      client.close();
    } catch (e) {
      status = _Status.error;
    }

    if (mounted && url == widget.page.url) {
      setState(() {
        _status = status;
        _file = file;
      });
    }
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
  Widget build(BuildContext context) {
    final content = switch (_status) {
      _Status.loading => Center(
        child: CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
        ),
      ),
      _Status.downloaded => Image.file(_file!, fit: BoxFit.contain),
      _Status.error => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.mangaReaderPageDownloadFailed),
            OutlinedButton(
              onPressed: () => _startDownload(widget.page.url),
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

enum _Status { loading, downloaded, error }
