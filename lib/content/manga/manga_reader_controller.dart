import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/utils.dart';
import 'package:strumok/download/manager/manga_pages_download_manager.dart';
import 'package:strumok/download/offline_storage.dart';

@immutable
class MangaReaderState extends Equatable {
  final bool initialized;
  final ValueNotifier<int> currentPage;
  final List<MangaPageInfo> pages;
  final int? currentItem;
  final String? currentSourceName;
  final MangaMediaItemSource? selectedSource;
  final String? error;
  final bool hasNext;
  final bool hasPrev;

  const MangaReaderState({
    this.initialized = false,
    required this.currentPage,
    this.pages = const [],
    this.hasNext = false,
    this.hasPrev = false,
    this.currentItem,
    this.currentSourceName,
    this.selectedSource,
    this.error,
  });

  factory MangaReaderState.uinitialized() {
    return MangaReaderState(currentPage: ValueNotifier(0));
  }

  factory MangaReaderState.erroneous(String error) {
    return MangaReaderState(
      initialized: true,
      currentPage: ValueNotifier(0),
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    initialized,
    currentPage.value,
    pages,
    currentItem,
    currentSourceName,
    selectedSource,
    error,
    hasNext,
    hasPrev,
  ];

  @override
  bool? get stringify => true;
}

const _preloadPagesAhead = 4;

class MangaReaderController extends ValueNotifier<MangaReaderState> {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ChangeCollectionCurrentItemCallback changeCollectionCurentItem;

  MangaReaderController({
    required this.contentDetails,
    required this.mediaItems,
    required this.changeCollectionCurentItem,
  }) : super(MangaReaderState.uinitialized());

  Future<void> update(MediaCollectionItem collectionItem) async {
    if (value.currentItem != collectionItem.currentItem ||
        value.currentSourceName != collectionItem.currentSourceName) {
      await _loadPages(collectionItem);
    }
  }

  Future<void> _loadPages(MediaCollectionItem collectionItem) async {
    value.currentPage.dispose();

    value = MangaReaderState.uinitialized();

    final currentItemIdx = collectionItem.currentItem;
    final currentSourceName = collectionItem.currentSourceName;

    final currentItem = mediaItems.firstWhere(
      (item) => item.number == currentItemIdx,
    );
    final sources = await currentItem.sources;

    if (currentItemIdx != collectionItem.currentItem ||
        currentSourceName != collectionItem.currentSourceName) {
      return;
    }

    final mangaSources = sources
        .where((s) => s.kind == FileKind.manga)
        .toList();

    final mangaSource = currentSourceName == null
        ? mangaSources.firstOrNull as MangaMediaItemSource?
        : mangaSources.firstWhereOrNull(
                (s) => s.description == currentSourceName,
              )
              as MangaMediaItemSource?;

    if (mangaSource == null) {
      value = MangaReaderState.erroneous("No sources found");
      return;
    }

    final pages = await mangaSource.pages;

    if (pages.isEmpty) {
      value = MangaReaderState.erroneous("No pages found");
      return;
    }

    if (currentItemIdx != collectionItem.currentItem ||
        currentSourceName != collectionItem.currentSourceName) {
      return;
    }

    value = MangaReaderState(
      initialized: true,
      currentPage: ValueNotifier(collectionItem.currentPosition),
      pages: pages
          .mapIndexed(
            (index, url) => MangaPageInfo(
              supplier: contentDetails.supplier,
              id: contentDetails.id,
              itemNum: currentItemIdx,
              source: mangaSource,
              pageNum: index,
              url: url,
            ),
          )
          .toList(),
      currentItem: currentItemIdx,
      currentSourceName: currentSourceName,
      selectedSource: mangaSource,
      hasNext: currentItemIdx < mediaItems.length - 1,
      hasPrev: currentItemIdx > 0,
    );

    value.currentPage.addListener(() {
      _preloadPages();
    });

    OfflineStorage().storeDetails(contentDetails);
    _preloadPages();
  }

  void _preloadPages() {
    final currentPageIndex = value.currentPage.value;

    final manager = MangaPagesDownloadManager();
    final endIndex = (currentPageIndex + _preloadPagesAhead).clamp(
      0,
      value.pages.length - 1,
    );

    for (int i = currentPageIndex + 1; i <= endIndex; i++) {
      final page = value.pages[i];

      // Skip if already downloading or downloaded
      if (manager.isDownloading(page.url)) {
        continue;
      }

      // Start background download without waiting
      manager.downloadPage(
        pageUrl: page.url,
        targetFile: getPageFile(page),
        headers: page.source.headers,
      );
    }
  }

  void nextPage() {
    if (value.currentPage.value < value.pages.length - 1) {
      value.currentPage.value = value.currentPage.value + 1;
    } else {
      nextItem();
    }
  }

  void prevPage() {
    if (value.currentPage.value != 0) {
      value.currentPage.value = value.currentPage.value - 1;
    } else {
      prevItem();
    }
  }

  void nextItem() {
    if (value.hasNext) {
      changeCollectionCurentItem(value.currentItem! + 1);
    }
  }

  void prevItem() {
    if (value.hasPrev) {
      changeCollectionCurentItem(value.currentItem! - 1);
    }
  }
}

class MangaReaderControllerInheritedWidget extends InheritedWidget {
  final MangaReaderController controller;

  const MangaReaderControllerInheritedWidget({
    super.key,
    required this.controller,
    required super.child,
  });

  static MangaReaderControllerInheritedWidget? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          MangaReaderControllerInheritedWidget
        >();
  }

  static MangaReaderControllerInheritedWidget of(BuildContext context) {
    final MangaReaderControllerInheritedWidget? result = maybeOf(context);
    assert(
      result != null,
      'No MangaReaderControllerInheritedWidget found in context',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(MangaReaderControllerInheritedWidget oldWidget) =>
      controller != oldWidget.controller;
}

MangaReaderController mangaReaderController(BuildContext context) =>
    MangaReaderControllerInheritedWidget.of(context).controller;
