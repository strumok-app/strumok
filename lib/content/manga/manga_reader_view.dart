import 'dart:async';

import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/manga_paged_viewer.dart';
import 'package:strumok/content/manga/manga_provider.dart';
import 'package:strumok/content/manga/manga_reader_controls.dart';
import 'package:strumok/content/manga/manga_scrolled_viewer.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
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
    );
  }
}

class _MangaPagesReaderView extends ConsumerStatefulWidget {
  final List<MangaPageInfo> pages;
  final int initialPage;
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider itemProvider;

  _MangaPagesReaderView({
    required this.pages,
    required this.initialPage,
    required this.contentDetails,
    required this.mediaItems,
  }) : itemProvider = collectionItemProvider(contentDetails);

  @override
  ConsumerState<_MangaPagesReaderView> createState() =>
      _MangaPagesReaderViewState();
}

class _MangaPagesReaderViewState extends ConsumerState<_MangaPagesReaderView>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> pageListenable;

  final scrollController = ScrollController();
  late final AnimatedScrollController animetedScrollController;

  @override
  void initState() {
    pageListenable = ValueNotifier(widget.initialPage);

    ref
        .read(widget.itemProvider.notifier)
        .setCurrentLength(widget.pages.length);

    final readerMode = ref.read(mangaReaderModeSettingsProvider);
    animetedScrollController = AnimatedScrollController(
      scrollController,
      readerMode.direction,
    );

    pageListenable.addListener(() {
      ref
          .read(widget.itemProvider.notifier)
          .setCurrentPosition(pageListenable.value);
    });

    super.initState();
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
        ShowUIIntent: CallbackAction<ShowUIIntent>(
          onInvoke: (_) => Navigator.of(context).push(
            MangaReaderControlsRoute(
              contentDetails: widget.contentDetails,
              mediaItems: widget.mediaItems,
              pagesController: pageListenable,
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
          ? MangaScrolledViewer(
              pages: widget.pages,
              direction: readerMode.direction,
              scrollController: scrollController,
              pageListenable: pageListenable,
            )
          : MangaPagedViewer(
              pages: widget.pages,
              direction: readerMode.direction,
              pageListenable: pageListenable,
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

      final newPos = pageListenable.value + inc;

      if (newPos < 0) {
        final contentProgress = await ref.read(provider.future);
        if (contentProgress.currentItem > 0) {
          notifier.setCurrentItem(contentProgress.currentItem - 1);
        }
      } else if (newPos >= widget.pages.length) {
        final contentProgress = await ref.read(provider.future);
        if (contentProgress.currentItem < widget.mediaItems.length - 1) {
          notifier.setCurrentItem(contentProgress.currentItem + 1);
        }
      } else {
        notifier.setCurrentPosition(newPos);
        pageListenable.value = newPos;
      }
    }
  }

  void _nextItem() async {
    final provider = widget.itemProvider;
    final notifier = ref.read(provider.notifier);
    final contentProgress = await ref.read(provider.future);
    if (contentProgress.currentItem < widget.mediaItems.length - 1) {
      notifier.setCurrentItem(contentProgress.currentItem + 1);
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
