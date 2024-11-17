import 'package:cached_network_image/cached_network_image.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/media_items_list.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Title
class MediaTitle extends ConsumerWidget {
  final int playlistSize;
  final ContentDetails contentDetails;

  const MediaTitle({
    super.key,
    required this.playlistSize,
    required this.contentDetails,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentItem = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .valueOrNull;

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    var title = contentDetails.title;

    if (playlistSize > 1) {
      title += " - ${currentItem + 1} / $playlistSize";
    }

    return Expanded(
      child: Text(
        title,
        style: const TextStyle(
          height: 1.0,
          fontSize: 22.0,
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

Widget playlistItemBuilder(
  ContentMediaItem item,
  ContentProgress? contentProgress,
  SelectCallback onSelect,
) {
  final progress = contentProgress?.positions[item.number]?.progress ?? 0;

  return VideoItemsListItem(
    item: item,
    selected: item.number == contentProgress?.currentItem,
    progress: progress,
    onTap: () {
      onSelect(item);
    },
  );
}

class VideoItemsListItem extends StatelessWidget {
  final ContentMediaItem item;
  final bool selected;
  final double progress;
  final VoidCallback onTap;

  const VideoItemsListItem({
    super.key,
    required this.item,
    required this.selected,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = item.title;
    final image = item.image;

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      color: selected ? theme.colorScheme.onInverseSurface : null,
      child: InkWell(
        autofocus: selected,
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 96,
              height: 72,
              decoration: BoxDecoration(
                image: image != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(image),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: image == null
                    ? theme.colorScheme.surfaceTint.withOpacity(0.5)
                    : null,
              ),
              child: selected
                  ? const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                title: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: LinearProgressIndicator(value: progress),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlayerErrorPopup extends StatelessWidget {
  final PlayerController playerController;

  const PlayerErrorPopup({
    super.key,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playerController.errors,
      builder: (context, value, child) {
        if (value.isEmpty) {
          return const SizedBox.shrink();
        }

        return Dropdown(
          anchorBuilder: (context, onPressed, child) => IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.warning_rounded),
            color: Colors.white,
            focusColor: Colors.white.withOpacity(0.4),
            disabledColor: Colors.white.withOpacity(0.7),
          ),
          menuChildrenBulder: (_) => [
            ...value.reversed
                .take(10)
                .map((error) => ListTile(title: Text(error)))
          ],
        );
      },
    );
  }
}
