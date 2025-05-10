import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/manga_provider.dart';
import 'package:strumok/content/manga/manga_reader_controls.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/back_nav_button.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MangaReaderView extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CurrentMangaPagesProvider _pagesProvider;
  final CollectionItemProvider _collectionItemProvider;

  MangaReaderView({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  }) : _pagesProvider = currentMangaPagesProvider(contentDetails, mediaItems),
       _collectionItemProvider = collectionItemProvider(contentDetails);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<ImageProvider>>>(_pagesProvider, (
      previous,
      next,
    ) {
      final images = next.valueOrNull;
      if (images != null) {
        ref
            .read(collectionItemProvider(contentDetails).notifier)
            .setCurrentLength(images.length);
      }
    });

    return ref
        .watch(_pagesProvider)
        .when(
          data: (pages) => _renderReader(context, ref, pages),
          error:
              (error, stackTrace) => DisplayError(
                error: error,
                onRefresh: () => ref.invalidate(_pagesProvider),
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }

  Widget _renderReader(
    BuildContext context,
    WidgetRef ref,
    List<ImageProvider> pages,
  ) {
    if (pages.isEmpty) {
      return _NoPagesView(
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      );
    }

    final pageFeature = ref.read(
      collectionItemCurrentPositionProvider(contentDetails).future,
    );

    return FutureBuilder(
      future: pageFeature,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return _MangaPagesReaderView(
          pages: pages,
          initialPage: snapshot.data!,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
          collectionItemProvider: _collectionItemProvider,
        );
      },
    );
  }
}

class _MangaPagesReaderView extends ConsumerStatefulWidget {
  final List<ImageProvider> pages;
  final int initialPage;
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider collectionItemProvider;

  const _MangaPagesReaderView({
    required this.pages,
    required this.initialPage,
    required this.contentDetails,
    required this.mediaItems,
    required this.collectionItemProvider,
  });

  @override
  ConsumerState<_MangaPagesReaderView> createState() =>
      _MangaPagesReaderViewState();
}

class _MangaPagesReaderViewState extends ConsumerState<_MangaPagesReaderView> {
  final transformationController = TransformationController();
  final scrollOffsetController = ScrollOffsetController();
  late final ValueNotifier<int> page;

  @override
  void initState() {
    page = ValueNotifier(widget.initialPage);

    if (isMobileDevice()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      WakelockPlus.enable();
    }

    super.initState();
  }

  @override
  void dispose() {
    if (isMobileDevice()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      WakelockPlus.disable();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

    return FocusableActionDetector(
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.arrowLeft): PrevPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp):
            (readerMode.scroll ? ScrollUpPageIntent() : PrevPageIntent()),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            (readerMode.scroll ? ScrollDownPageIntent() : NextPageIntent()),
        SingleActivator(LogicalKeyboardKey.select): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.space): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ShowUIIntent(),
      },
      actions: {
        PrevPageIntent: CallbackAction<PrevPageIntent>(
          onInvoke: (_) => _movePage(readerMode, -1),
        ),
        NextPageIntent: CallbackAction<NextPageIntent>(
          onInvoke: (_) => _movePage(readerMode, 1),
        ),
        ShowUIIntent: CallbackAction<ShowUIIntent>(
          onInvoke:
              (_) => Navigator.of(context).push(
                MangaReaderControlsRoute(
                  contentDetails: widget.contentDetails,
                  mediaItems: widget.mediaItems,
                  onPageChanged: _jumpToPage,
                ),
              ),
        ),
        ScrollUpPageIntent: CallbackAction<ScrollUpPageIntent>(
          onInvoke: (_) => _scrollTo(readerMode, 50),
        ),
        ScrollDownPageIntent: CallbackAction<ScrollDownPageIntent>(
          onInvoke: (_) => _scrollTo(readerMode, -50),
        ),
      },
      autofocus: true,
      child: Stack(
        children: [
          const MangaBackground(),
          _ReaderGestureDetector(
            readerMode: readerMode,
            transformationController: transformationController,
            child:
                readerMode.scroll
                    ? _ScrolledView(
                      readerMode: readerMode,
                      pages: widget.pages,
                      initialPage: page.value,
                      transformationController: transformationController,
                      scrollOffsetController: scrollOffsetController,
                      pageListinable: page,
                      collectionItemProvider: widget.collectionItemProvider,
                    )
                    : _PagedView(
                      readerMode: readerMode,
                      pages: widget.pages,
                      initialPage: page.value,
                      transformationController: transformationController,
                      pageListinable: page,
                    ),
          ),
        ],
      ),
    );
  }

  void _jumpToPage(int value) {
    ref.read(widget.collectionItemProvider.notifier).setCurrentPosition(value);
    page.value = value;
  }

  void _movePage(MangaReaderMode readerMode, int inc) async {
    inc = readerMode.rtl ? -inc : inc;

    final contentProgress = (await ref.read(
      widget.collectionItemProvider.future,
    ));
    final pos = contentProgress.currentPosition;

    final newPos = pos + inc;
    final notifier = ref.read(widget.collectionItemProvider.notifier);

    if (newPos < 0) {
      if (contentProgress.currentItem > 0) {
        notifier.setCurrentItem(contentProgress.currentItem - 1);
      }
    } else if (newPos >= widget.pages.length) {
      if (contentProgress.currentItem < widget.mediaItems.length - 1) {
        notifier.setCurrentItem(contentProgress.currentItem + 1);
      }
    } else {
      notifier.setCurrentPosition(newPos);
      page.value = newPos;
    }
  }

  void _scrollTo(MangaReaderMode readerMode, double inc) {
    if (readerMode.scroll) {
      scrollOffsetController.animateScroll(
        offset: -inc,
        duration: const Duration(milliseconds: 5),
        curve: Curves.linear,
      );
    }
  }
}

class _ReaderGestureDetector extends ConsumerStatefulWidget {
  final MangaReaderMode readerMode;
  final TransformationController transformationController;
  final Widget child;

  const _ReaderGestureDetector({
    required this.readerMode,
    required this.transformationController,
    required this.child,
  });

  @override
  ConsumerState<_ReaderGestureDetector> createState() =>
      _ReaderGestureDetectorState();
}

class _ReaderGestureDetectorState
    extends ConsumerState<_ReaderGestureDetector> {
  TapDownDetails? _lastTapDetails;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
      valueListenable: widget.transformationController,
      builder: (context, value, child) {
        return GestureDetector(
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
    final position =
        widget.readerMode.direction == Axis.horizontal ? point.dx : point.dy;
    final range =
        widget.readerMode.direction == Axis.horizontal
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
      Actions.invoke(context, const ShowUIIntent());
    }
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
      transfomationController.value =
          Matrix4.identity()
            ..translate(-position.dx, -position.dy)
            ..scale(2.0);
    }
  }
}

class _PagedView extends ConsumerStatefulWidget {
  final MangaReaderMode readerMode;
  final List<ImageProvider<Object>> pages;
  final int initialPage;
  final TransformationController transformationController;
  final ValueListenable<int> pageListinable;

  const _PagedView({
    required this.readerMode,
    required this.pages,
    required this.initialPage,
    required this.transformationController,
    required this.pageListinable,
  });

  @override
  ConsumerState<_PagedView> createState() => _PagedViewState();
}

class _PagedViewState extends ConsumerState<_PagedView> {
  PageController? _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialPage);
    widget.pageListinable.addListener(_onPageChanged);

    super.initState();
  }

  @override
  void dispose() {
    widget.pageListinable.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final pageNum = widget.pageListinable.value;
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
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      reverse: widget.readerMode.rtl,
      itemBuilder: (context, index) {
        return _SinglePageView(
          readerMode: widget.readerMode,
          page: widget.pages[index],
          transformationController: widget.transformationController,
        );
      },
      itemCount: widget.pages.length,
      scrollDirection: widget.readerMode.direction,
    );
  }
}

class _SinglePageView extends ConsumerWidget {
  final MangaReaderMode readerMode;
  final ImageProvider<Object> page;
  final TransformationController transformationController;

  const _SinglePageView({
    required this.readerMode,
    required this.page,
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
          child: _PageImage(
            readerMode: readerMode,
            constraints: constraints,
            page: page,
          ),
        );
      },
    );
  }
}

class _PageImage extends StatelessWidget {
  final MangaReaderMode readerMode;
  final BoxConstraints constraints;
  final ImageProvider<Object> page;

  const _PageImage({
    required this.readerMode,
    required this.constraints,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: constraints.maxHeight,
        minWidth: constraints.maxWidth,
      ),
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: Image(
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return MangaPagePlaceholder(
              readerMode: readerMode,
              constraints: constraints,
            );
          },
          fit: BoxFit.contain,
          image: page,
        ),
      ),
    );
  }
}

class _ScrolledView extends ConsumerStatefulWidget {
  final MangaReaderMode readerMode;
  final List<ImageProvider<Object>> pages;
  final int initialPage;
  final TransformationController transformationController;
  final ScrollOffsetController scrollOffsetController;
  final ValueListenable<int> pageListinable;
  final CollectionItemProvider collectionItemProvider;

  const _ScrolledView({
    required this.readerMode,
    required this.pages,
    required this.initialPage,
    required this.transformationController,
    required this.scrollOffsetController,
    required this.pageListinable,
    required this.collectionItemProvider,
  });

  @override
  ConsumerState<_ScrolledView> createState() => _ScrolledViewState();
}

class _ScrolledViewState extends ConsumerState<_ScrolledView> {
  bool isScaling = false;
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    widget.transformationController.addListener(_onTransformationChange);
    widget.pageListinable.addListener(_onPageChanged);
    _itemPositionsListener.itemPositions.addListener(_onPositionChanged);

    super.initState();
  }

  @override
  void dispose() {
    widget.transformationController.removeListener(_onTransformationChange);
    widget.pageListinable.removeListener(_onPageChanged);
    _itemPositionsListener.itemPositions.removeListener(_onPositionChanged);
    super.dispose();
  }

  void _onPositionChanged() {
    final firstItem = _itemPositionsListener.itemPositions.value.firstOrNull;
    final lastItem = _itemPositionsListener.itemPositions.value.lastOrNull;

    if (firstItem == null || lastItem == null) {
      return;
    }

    final pageIndex =
        (lastItem.index == widget.pages.length - 1 &&
                lastItem.itemTrailingEdge == 1.0)
            ? lastItem.index
            : firstItem.index;

    ref
        .watch(widget.collectionItemProvider.notifier)
        .setCurrentPosition(pageIndex);
  }

  void _onPageChanged() {
    _itemScrollController.scrollTo(
      index: widget.pageListinable.value,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onTransformationChange() {
    final newIsScale = widget.transformationController.value.isScaled();
    if (newIsScale != isScaling) {
      if (mounted) {
        setState(() {
          isScaling = newIsScale;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerMode = widget.readerMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          transformationController: widget.transformationController,
          scaleEnabled: isScaling,
          panEnabled: isScaling,
          child: ScrollablePositionedList.builder(
            reverse: readerMode.rtl,
            scrollDirection: readerMode.direction,
            scrollOffsetController: widget.scrollOffsetController,
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            physics:
                isScaling
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
            itemCount: widget.pages.length,
            initialScrollIndex: widget.initialPage,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    readerMode.direction == Axis.vertical && !isMobileDevice()
                        ? const EdgeInsets.symmetric(horizontal: 16.0)
                        : EdgeInsets.zero,
                child: Image(
                  fit:
                      readerMode.direction == Axis.vertical
                          ? BoxFit.fitWidth
                          : BoxFit.fitHeight,
                  image: widget.pages[index],
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return MangaPagePlaceholder(
                      readerMode: readerMode,
                      constraints: constraints,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _NoPagesView extends StatelessWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const _NoPagesView({required this.contentDetails, required this.mediaItems});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.mangaUnableToLoadPage,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BackNavButton(),
              const SizedBox(width: 8),
              MangaSettingsButton(
                contentDetails: contentDetails,
                mediaItems: mediaItems,
              ),
              const SizedBox(width: 8),
              VolumesButton(
                contentDetails: contentDetails,
                mediaItems: mediaItems,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on Matrix4 {
  bool isScaled() => entry(0, 0) != 1.0;
}
