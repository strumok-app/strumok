import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:strumok/offline/offline_storage.dart';

class OfflineContentDetails implements ContentDetails {
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
  @override
  final String description;
  @override
  final MediaType mediaType;

  List<ContentMediaItem>? _mediaItems;

  OfflineContentDetails._({
    required this.id,
    required this.supplier,
    required this.title,
    required this.secondaryTitle,
    required this.image,
    required this.description,
    required this.mediaType,
  });

  factory OfflineContentDetails.create(
    String id,
    String supplier,
    Map<String, Object?>? json,
  ) {
    final mediaTypeJson = json?["mediaType"]?.toString();
    final mediaType =
        MediaType.values.where((i) => i.name == mediaTypeJson).firstOrNull ??
        MediaType.video;

    return OfflineContentDetails._(
      id: id,
      supplier: supplier,
      title: json?["title"]?.toString() ?? "Unknown",
      secondaryTitle: json?["secondaryTitle"]?.toString(),
      image: json?["image"]?.toString() ?? "",
      description: json?["description"]?.toString() ?? "",
      mediaType: mediaType,
    );
  }

  @override
  List<String> get additionalInfo => const [];

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async =>
      _mediaItems ??= await OfflineStorage().getMediaItems(supplier, id);

  @override
  List<ContentInfo> get similar => const [];
}

class OfflineContenMediaItem extends Equatable implements ContentMediaItem {
  final String supplier;
  final String id;
  @override
  final String title;
  @override
  final int number;
  final int _folderNumber;

  const OfflineContenMediaItem(
    this.supplier,
    this.id,
    this.title,
    this.number,
    this._folderNumber,
  );

  @override
  List<Object?> get props => [supplier, id, number];

  @override
  String? get image => null;

  @override
  String? get section => null;

  @override
  Future<List<ContentMediaItemSource>> get sources async =>
      await OfflineStorage().getSources(supplier, id, _folderNumber);
}

class ContentDetailsWithOffline extends Equatable implements ContentDetails {
  const ContentDetailsWithOffline(this._actualDetails);

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
          (index, it) => ContentMediaItemWithOfflline(supplier, id, it),
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

class ContentMediaItemWithOfflline extends Equatable
    implements ContentMediaItem {
  final String supplier;
  final String id;
  final ContentMediaItem _actualMediaItem;

  const ContentMediaItemWithOfflline(
    this.supplier,
    this.id,
    this._actualMediaItem,
  );

  @override
  String? get image => _actualMediaItem.image;

  @override
  String? get section => _actualMediaItem.section;

  @override
  int get number => _actualMediaItem.number;

  @override
  String get title => _actualMediaItem.title;

  @override
  Future<List<ContentMediaItemSource>> get sources async {
    final offlineSources = await OfflineStorage().getSources(
      supplier,
      id,
      number,
    );

    final merged = <ContentMediaItemSource>[];
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

  OfflineContentInfo._({
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
    return OfflineContentInfo._(
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
