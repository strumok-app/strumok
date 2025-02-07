import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/media_items_list.dart';
import 'package:strumok/offline/media_item_download.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/utils/nav.dart';

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
            onSelect: onSelect ??
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

MediaItemsListBuilder mangaChapterListItemBuilder(ContentInfo contentInfo) {
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
      trailing: MediaItemDownloadButton(contentInfo: contentInfo, item: item),
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
    final pos = ref.watch(collectionItemCurrentMediaItemPositionProvider(contentDetails)).valueOrNull;

    if (pos == null || pos.length == 0) {
      return const SizedBox.shrink();
    }

    return LinearProgressIndicator(value: pos.progress);
  }
}

class MangaPagePlaceholder extends StatefulWidget {
  static const aspectRation = 1.5;
  final MangaReaderMode readerMode;
  final BoxConstraints constraints;

  const MangaPagePlaceholder({
    super.key,
    required this.readerMode,
    required this.constraints,
  });

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
      child: Container(
        width: widget.readerMode.direction == Axis.vertical
            ? widget.constraints.maxWidth
            : widget.constraints.maxHeight / MangaPagePlaceholder.aspectRation,
        height: widget.readerMode.direction == Axis.horizontal
            ? widget.constraints.maxHeight
            : widget.constraints.maxWidth * MangaPagePlaceholder.aspectRation,
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
