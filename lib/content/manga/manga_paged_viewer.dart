import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/manga_page_image.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/utils/matrix.dart';

class MangaPagedViewer extends ConsumerStatefulWidget {
  final List<MangaPageInfo> pages;
  final Axis direction;
  final ValueNotifier<int> pageListenable;

  const MangaPagedViewer({
    super.key,
    required this.pages,
    required this.direction,
    required this.pageListenable,
  });

  @override
  ConsumerState<MangaPagedViewer> createState() => _PagedViewState();
}

class _PagedViewState extends ConsumerState<MangaPagedViewer> {
  final _transformationController = TransformationController();
  late PageController _pageController;
  bool _scaling = false;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.pageListenable.value);
    _pageController.addListener(_hadlePageContoller);
    widget.pageListenable.addListener(_onPageChanged);
    _transformationController.addListener(_handleTransformationChange);

    super.initState();
  }

  void _hadlePageContoller() {
    final page = _pageController.page!;

    if (page.floor() == page && widget.pageListenable.value != page) {
      widget.pageListenable.value = page.toInt();
    }
  }

  @override
  void didUpdateWidget(covariant MangaPagedViewer oldWidget) {
    oldWidget.pageListenable.removeListener(_onPageChanged);

    widget.pageListenable.addListener(_onPageChanged);
    _pageController.jumpToPage(widget.pageListenable.value);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.pageListenable.removeListener(_onPageChanged);
    _transformationController.removeListener(_handleTransformationChange);

    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleTransformationChange() {
    final newScaling = _transformationController.value.isScaled();
    if (_scaling != newScaling) {
      if (mounted) {
        setState(() {
          _scaling = newScaling;
        });
      }
    }
  }

  void _onPageChanged() {
    final page = widget.pageListenable.value;

    if (page >= widget.pages.length) {
      return;
    }

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReaderGestureDetector(
      direction: widget.direction,
      transformationController: _transformationController,
      child: InteractiveViewer(
        maxScale: 5,
        minScale: 1,
        panEnabled: _scaling,
        scaleEnabled: _scaling,
        transformationController: _transformationController,
        child: PageView.builder(
          controller: _pageController,
          physics: _scaling
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return MangaPageImage(
              direction: widget.direction,
              page: widget.pages[index],
            );
          },
          itemCount: widget.pages.length,
          scrollDirection: widget.direction,
        ),
      ),
    );
  }
}

class _ReaderGestureDetector extends StatefulWidget {
  final Axis direction;
  final TransformationController transformationController;
  final Widget child;

  const _ReaderGestureDetector({
    required this.direction,
    required this.transformationController,
    required this.child,
  });

  @override
  State<_ReaderGestureDetector> createState() => _ReaderGestureDetectorState();
}

class _ReaderGestureDetectorState extends State<_ReaderGestureDetector> {
  TapDownDetails? _lastTapDetails;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
      valueListenable: widget.transformationController,
      builder: (context, value, child) {
        return GestureDetector(
          onDoubleTapDown: (details) => _lastTapDetails = details,
          onTapDown: (details) => _lastTapDetails = details,
          onDoubleTap: _toggleZoom,
          onTap: value.isScaled() ? null : _tapZones,
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.transparent,
            child: widget.child,
          ),
        );
      },
    );
  }

  bool _isInZone(int testZone, int zonesNum, Offset point) {
    final viewport = MediaQuery.sizeOf(context);
    final position = widget.direction == Axis.horizontal ? point.dx : point.dy;
    final range = widget.direction == Axis.horizontal
        ? viewport.width
        : viewport.height;

    final zoneSize = range / zonesNum.toDouble();
    final lowerBoundry = (testZone - 1) * zoneSize;
    final upperBoundry = testZone * zoneSize;

    return lowerBoundry <= position && position < upperBoundry;
  }

  void _tapZones() {
    if (_lastTapDetails == null) {
      return;
    }

    if (_isInZone(1, 3, _lastTapDetails!.globalPosition)) {
      Actions.invoke(context, const PrevPageIntent());
    } else if (_isInZone(3, 3, _lastTapDetails!.globalPosition)) {
      Actions.invoke(context, const NextPageIntent());
    } else {
      _toggleUI();
    }
  }

  void _toggleUI() {
    Actions.invoke(context, const ShowUIIntent());
  }

  void _toggleZoom() {
    if (_lastTapDetails == null) {
      return;
    }

    final position = _lastTapDetails!.globalPosition;
    final transfomationController = widget.transformationController;

    if (!transfomationController.value.isIdentity()) {
      transfomationController.value = Matrix4.identity();
    } else {
      transfomationController.value = Matrix4.identity()
        ..translateByDouble(-position.dx, -position.dy, 0, 1)
        ..scaleByDouble(2.0, 2.0, 2.0, 1.0);
    }
  }
}
