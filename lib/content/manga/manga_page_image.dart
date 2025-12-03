import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/download/manager/manga_pages_download_manager.dart';
import 'package:strumok/download/offline_storage.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/settings/settings_provider.dart';

class MangaPageImage extends ConsumerStatefulWidget {
  final MangaPageInfo page;
  final Axis direction;

  const MangaPageImage({
    super.key,
    required this.direction,
    required this.page,
  });

  @override
  ConsumerState<MangaPageImage> createState() => _MangaPageImageState();
}

class _MangaPageImageState extends ConsumerState<MangaPageImage> {
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
      _file = null;
      _initialize(widget.page);
    }
  }

  void _initialize(MangaPageInfo page) async {
    if (!mounted) return;

    if (page.url.startsWith('file://')) {
      final file = File(page.url.substring(7));
      setState(() {
        _file = file;
        _status = MangaPageDownloadStatus.completed;
      });
      return;
    }

    final path = _getPagePath();
    final file = File(path);
    if (await file.exists()) {
      if (mounted) {
        setState(() {
          _file = file;
          _status = MangaPageDownloadStatus.completed;
        });
      }
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

          if (event.status == MangaPageDownloadStatus.completed &&
              event.file != null) {
            _file = file;
          }
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
    final autoCropEnabled = ref.watch(mangaReaderAutoCropSettingsProvider);

    final content = switch (_status) {
      MangaPageDownloadStatus.loading => Center(
        child: CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
        ),
      ),
      MangaPageDownloadStatus.completed =>
        _file != null
            ? autoCropEnabled
                  ? _AutoCropPage(imageProvider: FileImage(_file!))
                  : Image(image: FileImage(_file!), fit: BoxFit.contain)
            : const SizedBox.shrink(),
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

class _AutoCropPage extends StatefulWidget {
  final ImageProvider imageProvider;

  const _AutoCropPage({required this.imageProvider});

  @override
  State<_AutoCropPage> createState() => _AutoCropPageState();
}

class _AutoCropPageState extends State<_AutoCropPage> {
  ui.Image? _image;
  Rect? _cropRect;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    // 1. Resolve the ImageProvider to a ui.Image
    final stream = widget.imageProvider.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener((ImageInfo info, bool _) async {
        final ui.Image image = info.image;

        // 2. Calculate the crop rect
        final Rect rect = await _calculateContentRect(image);

        if (mounted) {
          setState(() {
            _image = image;
            _cropRect = rect;
            _loading = false;
          });
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _image == null) {
      return SizedBox();
    }

    return ClipRect(
      child: CustomPaint(
        painter: _PageRectPainter(
          image: _image!,
          displayRect: _cropRect!,
          fit: BoxFit.contain,
        ),
        child: Container(),
      ),
    );
  }
}

class _PageRectPainter extends CustomPainter {
  final ui.Image image;
  final Rect displayRect;
  final BoxFit fit;

  const _PageRectPainter({
    required this.image,
    required this.displayRect,
    required this.fit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dstRect = _applyBoxFit(fit, displayRect.size, size);

    // Draw only the specified rectangle portion of the image
    canvas.drawImageRect(image, displayRect, dstRect, Paint());
  }

  Rect _applyBoxFit(BoxFit fit, Size srcSize, Size dstSize) {
    final FittedSizes fittedSizes = applyBoxFit(fit, srcSize, dstSize);
    final Size outputSize = fittedSizes.destination;

    final double dx = (dstSize.width - outputSize.width) / 2.0;
    final double dy = (dstSize.height - outputSize.height) / 2.0;

    return Rect.fromLTWH(dx, dy, outputSize.width, outputSize.height);
  }

  @override
  bool shouldRepaint(_PageRectPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.displayRect != displayRect ||
        oldDelegate.fit != fit;
  }
}

Future<Rect> _calculateContentRect(
  ui.Image image, {
  int threshold = 230,
  int stride = 10,
}) async {
  final int width = image.width;
  final int height = image.height;

  // Get raw RGBA bytes from the image
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );
  if (byteData == null) {
    return Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  }

  final Uint8List pixels = byteData.buffer.asUint8List();

  // Helper: Check if a pixel index is "dark" (content)
  // RGBA format: [R, G, B, A] -> 4 bytes per pixel
  bool isContent(int x, int y) {
    final int index = (y * width + x) * 4;
    final int r = pixels[index];
    final int g = pixels[index + 1];
    final int b = pixels[index + 2];

    // Simple average luminance
    return ((r + g + b) / 3) < threshold;
  }

  // Check every 10th row for speed
  int leftBound = 0;
  int rightBound = width;

  // Scan for Left Bound
  bool found = false;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y += stride) {
      if (isContent(x, y)) {
        leftBound = x;
        found = true;
        break;
      }
    }
    if (found) break;
  }

  // Scan for Right Bound
  found = false;
  for (int x = width - 1; x >= 0; x--) {
    for (int y = 0; y < height; y += stride) {
      if (isContent(x, y)) {
        rightBound = x + 1;
        found = true;
        break;
      }
    }
    if (found) break;
  }

  // Return the Rectangle of the content
  // We keep the full height (0 to height), but crop the width
  final cropRect = Rect.fromLTRB(
    leftBound.toDouble(),
    0.0,
    rightBound.toDouble(),
    height.toDouble(),
  );

  return cropRect;
}
