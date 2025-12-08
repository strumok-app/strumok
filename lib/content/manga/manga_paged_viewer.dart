import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/manga_page_image.dart';
import 'package:strumok/content/manga/manga_reader_controller.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/utils/matrix.dart';
import 'package:strumok/utils/visual.dart';

class MangaPagedViewer extends ConsumerStatefulWidget {
  final MangaReaderMode readerMode;
  final MangaReaderState readerState;

  const MangaPagedViewer({
    super.key,
    required this.readerMode,
    required this.readerState,
  });

  @override
  ConsumerState<MangaPagedViewer> createState() => _PagedViewState();
}

class _PagedViewState extends ConsumerState<MangaPagedViewer> {
  final _transformationController = TransformationController();
  final _focusNode = FocusNode(debugLabel: "manga_paged_viewer");
  late PageController _pageController;
  bool _scaling = false;

  @override
  void initState() {
    final currentPage = widget.readerState.currentPage;

    _pageController = PageController(initialPage: currentPage.value);
    _pageController.addListener(_hadlePageContoller);

    currentPage.addListener(_onPageChanged);
    _transformationController.addListener(_handleTransformationChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant MangaPagedViewer oldWidget) {
    final currentPage = widget.readerState.currentPage;
    currentPage.addListener(_onPageChanged);

    _pageController.removeListener(_hadlePageContoller);
    _pageController.jumpToPage(currentPage.value);
    _pageController.addListener(_hadlePageContoller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    final currentPage = widget.readerState.currentPage;

    currentPage.removeListener(_onPageChanged);
    _transformationController.removeListener(_handleTransformationChange);

    _pageController.dispose();
    _transformationController.dispose();
    _focusNode.dispose();

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

  void _hadlePageContoller() {
    final currentPage = widget.readerState.currentPage;
    final page = _pageController.page!;

    if (page.floor() == page && currentPage.value != page) {
      currentPage.value = page.toInt();
    }
  }

  void _onPageChanged() {
    final currentPage = widget.readerState.currentPage;
    final pages = widget.readerState.pages;

    final page = currentPage.value;

    if (page >= pages.length) {
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
    final direction = widget.readerMode.direction;
    final pages = widget.readerState.pages;

    return MangaReaderIteractions(
      readerMode: widget.readerMode,
      focusNode: _focusNode,
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.arrowLeft): PrevPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PrevPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): NextPageIntent(),
      },
      actions: {
        PrevPageIntent: CallbackAction<PrevPageIntent>(
          onInvoke: (_) => mangaReaderController(context).prevPage(),
        ),
        NextPageIntent: CallbackAction<NextPageIntent>(
          onInvoke: (_) => mangaReaderController(context).nextPage(),
        ),
      },
      child: _ReaderGestureDetector(
        direction: direction,
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
              return MangaPageImage(direction: direction, page: pages[index]);
            },
            itemCount: pages.length,
            scrollDirection: direction,
          ),
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

    if (isMobile(context)) {
      if (_isInZone(1, 3, _lastTapDetails!.globalPosition)) {
        Actions.invoke(context, const PrevPageIntent());
      } else if (_isInZone(3, 3, _lastTapDetails!.globalPosition)) {
        Actions.invoke(context, const NextPageIntent());
      } else {
        _toggleUI();
      }
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
