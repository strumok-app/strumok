import 'package:flutter/services.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/manga_reader_controller.dart';
import 'package:strumok/content/manga/manga_reader_controls.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/media_items_list.dart';
import 'package:strumok/download/media_item_download.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/utils/fullscrean.dart';
import 'package:strumok/utils/nav.dart';

import 'intents.dart';

const mangaPageAspectRatio = 1.42;

class VolumesButton extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final SelectCallback? onSelect;
  final Color? color;
  final bool autofocus;

  const VolumesButton({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    this.onSelect,
    this.color,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = collectionItemProvider(contentDetails);
    final contentItem = ref.watch(provider);

    return contentItem.maybeWhen(
      data: (data) => _renderButton(context, provider, ref, data),
      orElse: () => const SizedBox.shrink(),
    );
  }

  IconButton _renderButton(
    BuildContext context,
    CollectionItemProvider provider,
    WidgetRef ref,
    MediaCollectionItem? collectionItem,
  ) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MediaItemsListRoute(
            title: AppLocalizations.of(context)!.mangaChapter,
            mediaItems: mediaItems,
            contentProgress: collectionItem,
            onSelect:
                onSelect ??
                (item) {
                  ref.read(provider.notifier).setCurrentItem(item.number);
                  navigateToContent(context, contentDetails);
                },
            itemBuilder: mangaChapterListItemBuilder(contentDetails),
          ),
        );
      },
      icon: const Icon(Icons.list),
      color: color,
      tooltip: AppLocalizations.of(context)!.mangaChapter,
      autofocus: autofocus,
    );
  }
}

MediaItemsListBuilder mangaChapterListItemBuilder(
  ContentDetails contentDetails,
) {
  return (
    ContentMediaItem item,
    ContentProgress? contentProgress,
    SelectCallback onSelect,
  ) {
    final progress = contentProgress?.positions[item.number]?.progress ?? 0;

    return MediaItemsListItem(
      item: item,
      selected: item.number == contentProgress?.currentItem,
      selectIcon: Icons.menu_book,
      progress: progress,
      onTap: () {
        onSelect(item);
      },
      trailing: MediaItemDownloadButton(
        contentDetails: contentDetails,
        item: item,
      ),
    );
  };
}

class MangaBackground extends ConsumerWidget {
  const MangaBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);

    final currentBackground = ref.watch(mangaReaderBackgroundSettingsProvider);

    return Container(
      width: size.width,
      height: size.height,
      color: switch (currentBackground) {
        MangaReaderBackground.light => Colors.white,
        MangaReaderBackground.dark => Colors.black,
      },
    );
  }
}

class MangaChapterProgressIndicator extends ConsumerWidget {
  final ContentDetails contentDetails;

  const MangaChapterProgressIndicator({
    super.key,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref
        .watch(collectionItemCurrentMediaItemPositionProvider(contentDetails))
        .value;

    if (pos == null || pos.length == 0) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(value: pos.progress);
  }
}

class MangaPagePlaceholder extends StatefulWidget {
  final Axis direction;

  const MangaPagePlaceholder({super.key, required this.direction});

  @override
  State<MangaPagePlaceholder> createState() => _MangaPagePlaceholderState();
}

class _MangaPagePlaceholderState extends State<MangaPagePlaceholder> {
  double _opacity = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _opacity = 0;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1800),
      child: ManagPageAspectContainer(
        direction: widget.direction,
        color: Colors.grey.shade400,
      ),
      onEnd: () {
        setState(() {
          _opacity = _opacity == 0 ? 1.0 : 0.0;
        });
      },
    );
  }
}

class ManagPageAspectContainer extends StatelessWidget {
  final Widget? child;
  final Axis direction;
  final Color? color;

  const ManagPageAspectContainer({
    super.key,
    this.child,
    required this.direction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints(
        minWidth: direction == Axis.vertical
            ? size.width
            : size.height / mangaPageAspectRatio,
        minHeight: direction == Axis.horizontal
            ? size.height
            : size.width * mangaPageAspectRatio,
      ),
      color: color,
      child: child,
    );
  }
}

class MangaReaderIteractions extends StatelessWidget {
  final MangaReaderMode readerMode;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final Widget child;
  final FocusNode? focusNode;

  const MangaReaderIteractions({
    super.key,
    this.shortcuts,
    this.actions,
    this.focusNode,
    required this.readerMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: focusNode,
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.select): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.space): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ShowUIIntent(),
        SingleActivator(LogicalKeyboardKey.keyF): ToggleFullscreanIntent(),
        if (shortcuts != null) ...shortcuts!,
      },
      actions: {
        ShowUIIntent: CallbackAction<ShowUIIntent>(
          onInvoke: (_) {
            return Navigator.of(context).push(
              MangaReaderControlsRoute(
                mangaReaderController: mangaReaderController(context),
              ),
            );
          },
        ),
        ToggleFullscreanIntent: CallbackAction<ToggleFullscreanIntent>(
          onInvoke: (_) => toggleFullscreen(),
        ),
        if (actions != null) ...actions!,
      },
      child: child,
    );
  }
}
