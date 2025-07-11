import 'package:collection/collection.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/media_items_list.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/offline/media_item_download.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Title
class MediaTitle extends ConsumerWidget {
  const MediaTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentDetails = VideoContentView.currentContentDetails;
    final playlistSize = VideoContentView.currentMediaItems.length;

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

MediaItemsListBuilder playlistItemBuilder(ContentDetails contentDetails) {
  return (
    ContentMediaItem item,
    ContentProgress? contentProgress,
    SelectCallback onSelect,
  ) {
    final progress = contentProgress?.positions[item.number]?.progress ?? 0;

    return MediaItemsListItem(
      item: item,
      selected: item.number == contentProgress?.currentItem,
      selectIcon: Icons.play_arrow_rounded,
      progress: progress,
      onTap: () => onSelect(item),
      trailing: MediaItemDownloadButton(
        contentDetails: contentDetails,
        item: item,
      ),
    );
  };
}

class PlayerErrorPopup extends ConsumerWidget {
  const PlayerErrorPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errors = ref.watch(playerErrorsProvider);

    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Dropdown(
      anchorBuilder: (context, onPressed, child) => IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.warning_rounded),
        color: Colors.white,
        disabledColor: Colors.white.withValues(alpha: 0.7),
      ),
      menuChildrenBuilder: (focusNode) => [
        ...errors.reversed
            .take(10)
            .mapIndexed(
              (idx, error) => MenuItemButton(
                focusNode: idx == 0 ? focusNode : null,
                child: Text(error),
              ),
            ),
      ],
    );
  }
}

class VideoServersLoaderIndicator extends StatelessWidget {
  final Widget child;

  const VideoServersLoaderIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      child: Stack(
        children: [
          child,
          ValueListenableBuilder(
            valueListenable: VideoContentView.currentState.isLoading,
            builder: (context, value, child) {
              return value
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
