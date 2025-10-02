import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/utils/matrix.dart';

class MangaPagedViewer extends ConsumerStatefulWidget {
  final List<ImageProvider<Object>> pages;
  final Axis direction;
  final ValueListenable<int> pageListenable;

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
  PageController? _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.pageListenable.value);
    widget.pageListenable.addListener(_onPageChanged);

    super.initState();
  }

  @override
  void dispose() {
    widget.pageListenable.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final pageNum = widget.pageListenable.value;
    final pages = widget.pages;

    precacheImage(pages[pageNum], context);
    for (int i = 1; i < 2; i++) {
      final r = pageNum + i;
      final l = pageNum - i;

      if (r < pages.length) {
        precacheImage(pages[r], context);
      }

      if (l >= 0) {
        precacheImage(pages[l], context);
      }
    }

    _pageController?.animateToPage(
      pageNum,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReaderGestureDetector(
      direction: widget.direction,
      transformationController: _transformationController,
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _SinglePageView(
            direction: widget.direction,
            page: widget.pages[index],
            transformationController: _transformationController,
          );
        },
        itemCount: widget.pages.length,
        scrollDirection: widget.direction,
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

    if (!_isInZone(2, 3, position)) {
      return;
    }

    if (!transfomationController.value.isIdentity()) {
      transfomationController.value = Matrix4.identity();
    } else {
      // For a 3x zoom
      transfomationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }
}

class _SinglePageView extends ConsumerWidget {
  final ImageProvider<Object> page;
  final Axis direction;
  final TransformationController transformationController;

  const _SinglePageView({
    required this.page,
    required this.direction,
    required this.transformationController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 1,
          transformationController: transformationController,
          boundaryMargin: EdgeInsets.zero,
          child: MangaPageImage(
            direction: direction,
            constraints: constraints,
            page: page,
          ),
        );
      },
    );
  }
}
