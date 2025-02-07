import 'package:strumok/content/manga/manga_reader_view.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    return MangaReaderView(
      contentDetails: contentDetails,
      mediaItems: mediaItems,
    );
  }
}
