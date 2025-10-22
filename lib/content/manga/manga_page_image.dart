import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/download/offline_storage.dart';

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
    _initialize();
  }

  void _initialize() async {
    if (!mounted) return;
    final page = widget.page;
    if (page.url.startsWith('file://')) {
      _file = File(page.url.substring(7));
      _status = _Status.downloaded;
      setState(() {});
      return;
    }

    final path = await _getPagePath();
    final file = File(path);
    if (await file.exists()) {
      _file = file;
      _status = _Status.downloaded;
      setState(() {});
    } else {
      _startDownload();
    }
  }

  void _startDownload() async {
    _status = _Status.loading;
    _progress = 0;
    setState(() {});

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(widget.page.url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final path = await _getPagePath();
        final file = File(path);
        await file.create(recursive: true);
        final sink = file.openWrite();

        int total = response.contentLength;
        int received = 0;

        await for (var chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) {
            _progress = received / total;
            if (mounted) setState(() {});
          }
        }

        await sink.close();
        _file = file;
        _status = _Status.downloaded;
      } else {
        _status = _Status.error;
      }
      client.close();
    } catch (e) {
      _status = _Status.error;
    }
    if (mounted) setState(() {});
  }

  Future<String> _getPagePath() async {
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
            const Text('Download failed'),
            OutlinedButton(
              onPressed: _startDownload,
              child: const Text('Retry'),
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
