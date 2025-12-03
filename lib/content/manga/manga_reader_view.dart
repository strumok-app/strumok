import 'dart:async';

import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/manga_paged_viewer.dart';
import 'package:strumok/content/manga/manga_provider.dart';
import 'package:strumok/content/manga/manga_reader_controls.dart';
import 'package:strumok/content/manga/manga_long_strip_viewer.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/utils.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/download/manager/manga_pages_download_manager.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/fullscrean.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/back_nav_button.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

class MangaReaderView extends ConsumerStatefulWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReaderView({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  ConsumerState<MangaReaderView> createState() => _MangaReaderViewState();
}

class _MangaReaderViewState extends ConsumerState<MangaReaderView> {
  @override
  void initState() {
    if (isMobileDevice()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }

    WakelockPlus.enable();

    super.initState();
  }

  @override
  void dispose() {
    if (isMobileDevice()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else if (isDesktopDevice()) {
      windowManager.setFullScreen(false);
    }

    WakelockPlus.disable();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagesProvider = currentMangaPagesProvider(
      widget.contentDetails,
      widget.mediaItems,
    );
    return ref
        .watch(pagesProvider)
        .when(
          data: (pages) => _renderReader(context, ref, pages),
          error: (error, stackTrace) => DisplayError(
            error: error,
            onRefresh: () => ref.invalidate(pagesProvider),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }

  Widget _renderReader(
    BuildContext context,
    WidgetRef ref,
    List<MangaPageInfo> pages,
  ) {
    if (pages.isEmpty) {
      return _NoPagesView(
        contentDetails: widget.contentDetails,
        mediaItems: widget.mediaItems,
      );
    }

    final collectionItem = ref
        .read(collectionItemProvider(widget.contentDetails))
        .requireValue;

    return _MangaPagesReaderView(
      pages: pages,
      initialPage: collectionItem.currentPosition,
      contentDetails: widget.contentDetails,
      mediaItems: widget.mediaItems,
      hasNextChapter: collectionItem.currentItem < widget.mediaItems.length - 1,
      hasPrevChapter: collectionItem.currentItem > 0,
    );
  }
}

class _MangaPagesReaderView extends ConsumerStatefulWidget {
  final List<MangaPageInfo> pages;
  final int initialPage;
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider itemProvider;
  final bool hasPrevChapter;
  final bool hasNextChapter;

  _MangaPagesReaderView({
    required this.pages,
    required this.initialPage,
    required this.contentDetails,
    required this.mediaItems,
    required this.hasPrevChapter,
    required this.hasNextChapter,
  }) : itemProvider = collectionItemProvider(contentDetails);

  @override
  ConsumerState<_MangaPagesReaderView> createState() =>
      _MangaPagesReaderViewState();
}

class _MangaPagesReaderViewState extends ConsumerState<_MangaPagesReaderView>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _pageListenable;

  final scrollController = ScrollController();
  late final AnimatedScrollController animetedScrollController;

  // Preload N pages ahead
  static const _preloadPagesAhead = 3;

  @override
  void initState() {
    ref
        .read(widget.itemProvider.notifier)
        .setCurrentLength(widget.pages.length);

    final readerMode = ref.read(mangaReaderModeSettingsProvider);
    animetedScrollController = AnimatedScrollController(
      scrollController,
      readerMode.direction,
    );

    _pageListenable = ValueNotifier(widget.initialPage);
    _pageListenable.addListener(_onPageChanged);

    super.initState();
  }

  @override
  void dispose() {
    _pageListenable.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MangaPagesReaderView oldWidget) {
    _pageListenable.dispose();

    _pageListenable = ValueNotifier(widget.initialPage);
    _pageListenable.addListener(_onPageChanged);

    super.didUpdateWidget(oldWidget);
  }

  void _onPageChanged() {
    final currentPage = _pageListenable.value;

    ref.read(widget.itemProvider.notifier).setCurrentPosition(currentPage);

    // Preload N pages ahead
    _preloadPages(currentPage);
  }

  void _preloadPages(int currentPageIndex) {
    final manager = MangaPagesDownloadManager();
    final endIndex = (currentPageIndex + _preloadPagesAhead).clamp(
      0,
      widget.pages.length - 1,
    );

    for (int i = currentPageIndex + 1; i <= endIndex; i++) {
      final page = widget.pages[i];

      // Skip if already downloading or downloaded
      if (manager.isDownloading(page.url)) {
        continue;
      }

      // Start background download without waiting
      manager.downloadPage(
        pageUrl: page.url,
        targetFile: getPageFile(page),
        headers: page.source.headers,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

    ref.listen(mangaReaderModeSettingsProvider, (p, n) {
      if (n.scroll) {
        animetedScrollController.direction = n.direction;
      } else {
        animetedScrollController.stop();
      }
    });

    return FocusableActionDetector(
      focusNode: FocusNode(debugLabel: "manga view"),
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.arrowLeft): PrevPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): NextPageIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): (readerMode.scroll
            ? ScrollUpPageIntent()
            : PrevPageIntent()),
        SingleActivator(LogicalKeyboardKey.arrowDown): (readerMode.scroll
            ? ScrollDownPageIntent()
            : NextPageIntent()),
        SingleActivator(LogicalKeyboardKey.select): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.space): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.keyF): ToggleFullscreanIntent(),
      },
      actions: {
        PrevPageIntent: CallbackAction<PrevPageIntent>(
          onInvoke: (_) => _movePage(readerMode, false),
        ),
        NextPageIntent: CallbackAction<NextPageIntent>(
          onInvoke: (_) => _movePage(readerMode, true),
        ),
        NextChapterIntent: CallbackAction<NextChapterIntent>(
          onInvoke: (_) => _nextItem(),
        ),
        PrevChapterIntent: CallbackAction<PrevChapterIntent>(
          onInvoke: (_) => _prevItem(),
        ),
        ShowUIIntent: CallbackAction<ShowUIIntent>(
          onInvoke: (_) => Navigator.of(context).push(
            MangaReaderControlsRoute(
              contentDetails: widget.contentDetails,
              mediaItems: widget.mediaItems,
              pagesController: _pageListenable,
            ),
          ),
        ),
        ScrollUpPageIntent: CallbackAction<ScrollUpPageIntent>(
          onInvoke: (_) => _scrollTo(readerMode, false),
        ),
        ScrollDownPageIntent: CallbackAction<ScrollDownPageIntent>(
          onInvoke: (_) => _scrollTo(readerMode, true),
        ),
        ToggleFullscreanIntent: CallbackAction<ToggleFullscreanIntent>(
          onInvoke: (_) => toggleFullscreen(),
        ),
      },
      autofocus: true,
      child: readerMode.scroll
          ? MangaLongStripViewer(
              pages: widget.pages,
              direction: readerMode.direction,
              scrollController: scrollController,
              pageListenable: _pageListenable,
              hasPrevChapter: widget.hasPrevChapter,
              hasNextChapter: widget.hasNextChapter,
            )
          : MangaPagedViewer(
              pages: widget.pages,
              direction: readerMode.direction,
              pageListenable: _pageListenable,
            ),
    );
  }

  void _movePage(MangaReaderMode readerMode, bool forward) async {
    if (readerMode.scroll) {
      animetedScrollController.scrollScrean(context, forward);
    } else {
      int inc = forward ? 1 : -1;

      final provider = widget.itemProvider;
      final notifier = ref.read(provider.notifier);

      final newPos = _pageListenable.value + inc;

      if (newPos < 0) {
        if (widget.hasPrevChapter) {
          final contentProgress = await ref.read(provider.future);
          notifier.setCurrentItem(contentProgress.currentItem - 1);
        }
      } else if (newPos >= widget.pages.length) {
        if (widget.hasNextChapter) {
          final contentProgress = await ref.read(provider.future);
          notifier.setCurrentItem(contentProgress.currentItem + 1);
        }
      } else {
        notifier.setCurrentPosition(newPos);
        _pageListenable.value = newPos;
      }
    }
  }

  void _nextItem() async {
    if (widget.hasNextChapter) {
      final provider = widget.itemProvider;
      final notifier = ref.read(provider.notifier);
      final contentProgress = await ref.read(provider.future);
      notifier.setCurrentItem(contentProgress.currentItem + 1);
    }
  }

  void _prevItem() async {
    if (widget.hasPrevChapter) {
      final provider = widget.itemProvider;
      final notifier = ref.read(provider.notifier);
      final contentProgress = await ref.read(provider.future);
      notifier.setCurrentItem(contentProgress.currentItem - 1);
    }
  }

  void _scrollTo(MangaReaderMode readerMode, bool forward) async {
    if (readerMode.scroll) {
      animetedScrollController.scroll(context, forward);
    }
  }
}

class AnimatedScrollController {
  final ScrollController _controller;
  Axis _direction;

  static const animationTime = 200;

  DateTime _lastTimestamp = DateTime.timestamp();
  Timer? _timer;
  double _speed = 0;
  double _distanceLeftToScroll = 0;
  bool running = false;

  AnimatedScrollController(this._controller, this._direction);

  void scrollScrean(BuildContext context, bool forward) {
    final size = MediaQuery.of(context).size;
    final dist = _direction == Axis.vertical ? size.height : size.width;

    _scrollDist(forward, dist);
  }

  void scroll(BuildContext context, bool forward) {
    _scrollDist(forward, 200);
  }

  void _scrollDist(bool forward, double dist) {
    _distanceLeftToScroll = dist;
    _speed = _distanceLeftToScroll / animationTime;

    if (!forward) {
      _speed = -_speed;
    }

    _startScrolling();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  set direction(Axis d) {
    stop();
    _direction = d;
  }

  void _startScrolling() {
    if (_timer != null) {
      return;
    }

    _lastTimestamp = DateTime.timestamp();
    _timer = Timer.periodic(Duration(milliseconds: 16), _scroll);
  }

  void _scroll(Timer timer) {
    final timestamp = DateTime.timestamp();
    final timeElapsed = timestamp.difference(_lastTimestamp).inMilliseconds;
    _lastTimestamp = timestamp;

    final dist = _speed * timeElapsed;
    double targetPos = _controller.offset + dist;

    if (targetPos < _controller.position.minScrollExtent) {
      targetPos = _controller.position.minScrollExtent;
    } else if (targetPos > _controller.position.maxScrollExtent) {
      targetPos = _controller.position.maxScrollExtent;
    }

    _controller.jumpTo(targetPos);

    _distanceLeftToScroll -= dist.abs();

    if (_distanceLeftToScroll <= 0) {
      stop();
    }
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
