import 'package:strumok/collection/collection_item_provider.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_provider.g.dart';

@riverpod
Future<List<MangaMediaItemSource>> mangaMediaItemSources(
  Ref ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final currentItem = await ref.watch(
    collectionItemCurrentItemProvider(contentDetails).future,
  );

  final currentChapter = mediaItems.elementAtOrNull(currentItem);

  if (currentChapter == null) {
    return const [];
  }

  final sources = await currentChapter.sources;

  return sources.cast();
}

@riverpod
Future<MangaMediaItemSource?> currentMangaMediaItemSource(
  Ref ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final sources = await ref.watch(
    mangaMediaItemSourcesProvider(contentDetails, mediaItems).future,
  );

  final currentSource = await ref.watch(
    collectionItemCurrentSourceNameProvider(contentDetails).future,
  );

  return currentSource == null
      ? sources.firstOrNull
      : sources.firstWhereOrNull((s) => s.description == currentSource);
}

@riverpod
Future<List<MangaPageInfo>> currentMangaPages(
  Ref ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final itemNum = await ref.watch(
    collectionItemCurrentItemProvider(contentDetails).future,
  );

  final currentSource = await ref.watch(
    currentMangaMediaItemSourceProvider(contentDetails, mediaItems).future,
  );

  if (currentSource == null) {
    return [];
  }

  final pages = await currentSource.pages;

  return pages
      .mapIndexed(
        (index, url) => MangaPageInfo(
          supplier: contentDetails.supplier,
          id: contentDetails.id,
          itemNum: itemNum,
          source: currentSource,
          pageNum: index,
          url: url,
        ),
      )
      .toList();
}
