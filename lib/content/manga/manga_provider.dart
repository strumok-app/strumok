import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
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

  return (await currentChapter.sources).cast();
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
Future<List<ImageProvider>> currentMangaPages(
  Ref ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final currentSource = await ref.watch(
    currentMangaMediaItemSourceProvider(contentDetails, mediaItems).future,
  );

  if (currentSource == null) {
    return [];
  }

  final pages = (await currentSource.pages)
      .map((url) => CachedNetworkImageProvider(url))
      .toList();

  return pages;
}
