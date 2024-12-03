import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/manga_provider.dart';
import 'package:strumok/content/manga/manga_reader_view.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/utils/trace.dart';

class MangaReader extends HookConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReader({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    traceAction(
      "load_video",
      description:
          "supplier: ${contentDetails.supplier}, id: ${contentDetails.id}",
    );

    ref.listen<AsyncValue<MangaMediaItemSource?>>(
      mangaChapterScanProvider(contentDetails, mediaItems),
      (previous, next) {
        final chapter = next.valueOrNull;
        if (chapter != null) {
          ref
              .read(collectionItemProvider(contentDetails).notifier)
              .setCurrentLength(chapter.pageNambers);
        }
      },
    );

    return MangaReaderView(
      contentDetails: contentDetails,
      mediaItems: mediaItems,
    );
  }
}
