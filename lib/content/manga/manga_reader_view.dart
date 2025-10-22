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
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/back_nav_button.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    ref.listen<AsyncValue<List<MangaPageInfo>>>(_pagesProvider, (
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
          error: (error, stackTrace) => DisplayError(
            error: error,
            onRefresh: () => ref.invalidate(_pagesProvider),
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
  final List<MangaPageInfo> pages;
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

class _MangaPagesReaderViewState extends ConsumerState<_MangaPagesReaderView>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> pageListenable;

  final scrollController = ScrollController();
  late final AnimatedScrollController animetedScrollController;

  @override
  void initState() {
    pageListenable = ValueNotifier(widget.initialPage);

    if (isMobileDevice()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }

    WakelockPlus.enable();

    final readerMode = ref.read(mangaReaderModeSettingsProvider);
    animetedScrollController = AnimatedScrollController(
      scrollController,
      readerMode.direction,
    );

    pageListenable.addListener(() {
      ref
          .read(widget.collectionItemProvider.notifier)
          .setCurrentPosition(pageListenable.value);
    });

    super.initState();
  }

  @override
  void dispose() {
    if (isMobileDevice()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    WakelockPlus.disable();

    super.dispose();
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
      },
      actions: {
        PrevPageIntent: CallbackAction<PrevPageIntent>(
          onInvoke: (_) => _movePage(readerMode, false),
        ),
        NextPageIntent: CallbackAction<NextPageIntent>(
          onInvoke: (_) => _movePage(readerMode, true),
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
      },
      autofocus: true,
      child: Stack(
        children: [
          const MangaBackground(),
          readerMode.scroll
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
        ],
      ),
    );
  }

  void _movePage(MangaReaderMode readerMode, bool forward) async {
    if (readerMode.scroll) {
      animetedScrollController.scrollScrean(context, forward);
    } else {
      int inc = forward ? 1 : -1;

      final provider = widget.collectionItemProvider;
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
