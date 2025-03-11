import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:strumok/offline/offline_storage.dart';

class ContentDetailsWithOfflineMedia extends Equatable
    implements ContentDetails {
  const ContentDetailsWithOfflineMedia(this._actualDetails);

  final ContentDetails _actualDetails;

  @override
  List<String> get additionalInfo => _actualDetails.additionalInfo;

  @override
  String get description => _actualDetails.description;

  @override
  String get id => _actualDetails.id;

  @override
  String get image => _actualDetails.image;

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async {
    final onlineMediaItems = await _actualDetails.mediaItems;

    return onlineMediaItems
        .mapIndexed(
          (index, it) => OfflineContentMediaItem(supplier, id, it, index),
        )
        .toList();
  }

  @override
  MediaType get mediaType => _actualDetails.mediaType;

  @override
  String? get secondaryTitle => _actualDetails.secondaryTitle;

  @override
  List<ContentInfo> get similar => _actualDetails.similar;

  @override
  String get supplier => _actualDetails.supplier;

  @override
  String get title => _actualDetails.title;

  @override
  List<Object?> get props => [supplier, id];
}

class OfflineContentMediaItem extends Equatable implements ContentMediaItem {
  final String supplier;
  final String id;
  final ContentMediaItem? _actualMediaItem;

  @override
  final int number;

  const OfflineContentMediaItem(
    this.supplier,
    this.id,
    this._actualMediaItem,
    this.number,
  );

  @override
  String? get image => _actualMediaItem?.image;

  @override
  String? get section => _actualMediaItem?.section;

  @override
  Future<List<ContentMediaItemSource>> get sources async {
    final merged = <ContentMediaItemSource>[];
    final offlineSources = await OfflineStorage().getSources(
      supplier,
      id,
      number,
    );

    if (_actualMediaItem != null) {
      merged.addAll(offlineSources);

      final onlineSources = await _actualMediaItem.sources;

      for (final source in onlineSources) {
        final notAvalaibleOffline =
            offlineSources
                .where((it) => it.description == source.description)
                .firstOrNull ==
            null;

        if (notAvalaibleOffline) {
          merged.add(source);
        }
      }

      return merged;
    }
    return offlineSources;
  }

  @override
  String get title => _actualMediaItem?.title ?? "Episode $number";

  @override
  List<Object?> get props => [supplier, id, number];
}

class OfflineContentInfo implements ContentInfo {
  @override
  final String id;
  @override
  final String supplier;
  @override
  final String title;
  @override
  final String? secondaryTitle;
  @override
  final String image;
  final int diskUsage;

  OfflineContentInfo({
    required this.id,
    required this.supplier,
    required this.title,
    required this.secondaryTitle,
    required this.image,
    required this.diskUsage,
  });

  factory OfflineContentInfo.create(
    String id,
    String supplier,
    Map<String, Object?>? json,
    int diskUsage,
  ) {
    return OfflineContentInfo(
      id: id,
      supplier: supplier,
      title: json?["title"]?.toString() ?? "Unknown",
      secondaryTitle: json?["secondaryTitle"]?.toString(),
      image: json?["image"]?.toString() ?? "",
      diskUsage: diskUsage,
    );
  }
}

// marker interface
interface class OfflineContenItemSource {}

class OfflineContentMediaItemSource extends SimpleContentMediaItemSource
    implements OfflineContenItemSource {
  const OfflineContentMediaItemSource({
    required super.description,
    required super.link,
  });
}

class OfflineMangaMediaItemSource
    implements MangaMediaItemSource, OfflineContenItemSource {
  @override
  final String description;
  final String dir;

  List<String>? _pages;

  OfflineMangaMediaItemSource({required this.description, required this.dir});

  @override
  FutureOr<List<String>> get pages async {
    return _pages ??= await _loadPages();
  }

  Future<List<String>> _loadPages() async {
    final orderedPages = SplayTreeMap<int, String>();

    await for (final entry in Directory(dir).list()) {
      if (entry is File && entry.path.endsWith(".jpg")) {
        final [numStr, _] = entry.uri.pathSegments.last.split(".");
        final num = int.tryParse(numStr);

        if (num != null) {
          orderedPages[num] = entry.path;
        }
      }
    }

    return orderedPages.values.toList();
  }

  @override
  FutureOr<List<ImageProvider<Object>>> get images async {
    return (await pages).map((path) => FileImage(File(path))).toList();
  }

  @override
  final FileKind kind = FileKind.manga;
}
