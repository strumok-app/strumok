import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Title
class MediaTitle extends ConsumerWidget {
  const MediaTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = videoContentController(context);
    final contentDetails = controller.contentDetails;
    final playlistSize = controller.mediaItems.length;

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
