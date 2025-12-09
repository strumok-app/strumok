import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/manga_long_strip_viewer.dart';
import 'package:strumok/content/manga/manga_paged_viewer.dart';
import 'package:strumok/content/manga/manga_reader_controller.dart';
import 'package:strumok/content/manga/manga_reader_controls.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/back_nav_button.dart';
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
  late final MangaReaderController controller;

  late final ProviderSubscription? _providerSubscription;

  @override
  void initState() {
    if (isMobileDevice()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }

    WakelockPlus.enable();

    final provider = collectionItemProvider(widget.contentDetails);
    final notifier = ref.read(provider.notifier);

    controller = MangaReaderController(
      contentDetails: widget.contentDetails,
      mediaItems: widget.mediaItems,
      changeCollectionCurentItem: (itemIdx) => notifier.setCurrentItem(itemIdx),
    );

    controller.addListener(() {
      var mangaReaderState = controller.value;

      if (!mangaReaderState.initialized) {
        return;
      }

      notifier.setCurrentLength(mangaReaderState.pages.length);

      mangaReaderState.currentPage.addListener(() {
        notifier.setCurrentPosition(mangaReaderState.currentPage.value);
      });
    });

    _providerSubscription = ref.listenManual(provider, (prev, next) {
      final nextValue = next.value;
      if (nextValue != null) {
        controller.update(nextValue);
      }
    }, fireImmediately: true);

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

    controller.dispose();
    _providerSubscription?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readerMode = ref.watch(mangaReaderModeSettingsProvider);

    return MangaReaderControllerInheritedWidget(
      controller: controller,
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, _) {
          if (!state.initialized) {
            return _UninitilizedView(
              readerMode: readerMode,
              readerState: state,
            );
          }

          return readerMode.scroll
              ? MangaLongStripViewer(readerMode: readerMode, readerState: state)
              : MangaPagedViewer(readerMode: readerMode, readerState: state);
        },
      ),
    );
  }
}

class _UninitilizedView extends StatefulWidget {
  final MangaReaderMode readerMode;
  final MangaReaderState readerState;

  const _UninitilizedView({
    required this.readerMode,
    required this.readerState,
  });

  @override
  State<_UninitilizedView> createState() => _UninitilizedViewState();
}

class _UninitilizedViewState extends State<_UninitilizedView> {
  final _focusNode = FocusNode(debugLabel: "_UninitilizedViewState");

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MangaReaderIteractions(
      focusNode: _focusNode,
      readerMode: widget.readerMode,
      child: Center(
        child:
            widget.readerState.error == null || widget.readerState.pages.isEmpty
            ? CircularProgressIndicator()
            : Text(AppLocalizations.of(context)!.mangaUnableToLoadPage),
      ),
    );
  }
}
