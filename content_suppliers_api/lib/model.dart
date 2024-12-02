import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum ContentType {
  movie,
  anime,
  cartoon,
  series,
  manga,
}

enum ContentLanguage {
  en("EN"),
  uk("UK"),
  multi("Multi");

  final String label;

  const ContentLanguage(this.label);
}

enum MediaType {
  video,
  manga,
}

abstract class ContentSupplier {
  String get name;
  Set<String> get channels => const {};
  Set<String> get defaultChannels => const {};
  Set<ContentType> get supportedTypes => const {};
  Set<ContentLanguage> get supportedLanguages => const {};
  Future<List<ContentInfo>> search(
    String query,
    Set<ContentType> type,
  ) async =>
      const [];

  Future<List<ContentInfo>> loadChannel(
    String channel, {
    int page = 0,
  }) async =>
      const [];
  Future<ContentDetails?> detailsById(String id) async => null;
}

abstract interface class ContentInfo {
  String get id;
  String get supplier;
  String get title;
  String? get secondaryTitle;
  String get image;
}

abstract interface class ContentMediaItem {
  int get number;
  String get title;
  FutureOr<List<ContentMediaItemSource>> get sources;
  String? get section;
  String? get image;
}

enum FileKind { video, manga, subtitle }

abstract interface class ContentMediaItemSource {
  FileKind get kind;
  String get description;
}

abstract interface class MediaFileItemSource extends ContentMediaItemSource {
  FutureOr<Uri> get link;
  Map<String, String>? get headers;
}

abstract interface class MangaMediaItemSource extends ContentMediaItemSource {
  int get pageNambers;
  FutureOr<List<ImageProvider>> allPages();
}

abstract interface class ContentDetails {
  String get id;
  String get supplier;
  String get title;
  String? get originalTitle;
  String get image;
  String get description;
  MediaType get mediaType;
  List<String> get additionalInfo;
  List<ContentInfo> get similar;
  FutureOr<Iterable<ContentMediaItem>> get mediaItems;
}

@immutable
@JsonSerializable()
class ContentSearchResult extends Equatable implements ContentInfo {
  @override
  final String id;
  @override
  final String supplier;
  @override
  final String image;
  @override
  final String title;
  @override
  final String? secondaryTitle;

  const ContentSearchResult({
    required this.id,
    required this.supplier,
    required this.image,
    required this.title,
    required this.secondaryTitle,
  });

  factory ContentSearchResult.fromJson(Map<String, dynamic> json) =>
      _$ContentSearchResultFromJson(json);

  static List<ContentSearchResult> fromJsonList(List<dynamic> json) =>
      json.map((e) => ContentSearchResult.fromJson(e)).toList();

  Map<String, dynamic> toJson() => _$ContentSearchResultToJson(this);

  @override
  List<Object?> get props => [id, supplier, image, title, secondaryTitle];
}

abstract class AbstractContentDetails extends Equatable
    implements ContentDetails {
  @override
  final String id;
  @override
  final String supplier;
  @override
  final String title;
  @override
  final String? originalTitle;
  @override
  final String image;
  @override
  final String description;
  @override
  @JsonKey(defaultValue: [])
  final List<String> additionalInfo;
  @override
  @JsonKey(
    defaultValue: [],
    fromJson: ContentSearchResult.fromJsonList,
  )
  final List<ContentInfo> similar;
  @override
  MediaType get mediaType => MediaType.video;
  @override
  FutureOr<Iterable<ContentMediaItem>> get mediaItems => const [];

  const AbstractContentDetails({
    required this.id,
    required this.supplier,
    required this.title,
    required this.originalTitle,
    required this.image,
    required this.description,
    required this.additionalInfo,
    required this.similar,
  });

  @override
  List<Object?> get props => [
        id,
        supplier,
        title,
        originalTitle,
        image,
        description,
        additionalInfo,
        similar
      ];
}

abstract class AbstractContentMediaItem extends Equatable
    implements ContentMediaItem {
  @override
  final int number;
  @override
  final String title;
  @override
  final String? section;
  @override
  final String? image;

  const AbstractContentMediaItem({
    required this.number,
    required this.title,
    this.section,
    this.image,
  });

  @override
  List<Object?> get props => [number];
}

abstract interface class ContentMediaItemLoader {
  FutureOr<List<ContentMediaItem>> call();
}

abstract interface class ContentMediaItemSourceLoader {
  FutureOr<List<ContentMediaItemSource>> call();
}

// ignore: must_be_immutable
class AsyncContentMediaItem extends AbstractContentMediaItem {
  List<ContentMediaItemSource>? _cachedSources;

  @override
  Future<List<ContentMediaItemSource>> get sources async =>
      _cachedSources ??= await sourcesLoader();

  final ContentMediaItemSourceLoader sourcesLoader;

  AsyncContentMediaItem({
    required super.number,
    required super.title,
    required this.sourcesLoader,
    super.section,
    super.image,
  });
}

@immutable
class SimpleContentMediaItem extends AbstractContentMediaItem {
  @override
  final List<ContentMediaItemSource> sources;

  const SimpleContentMediaItem({
    required super.number,
    required super.title,
    required this.sources,
    super.section,
    super.image,
  });
}

@immutable
class SimpleContentMediaItemSource extends Equatable
    implements MediaFileItemSource {
  @override
  final FileKind kind;
  @override
  final String description;
  @override
  final Uri link;
  @override
  final Map<String, String>? headers;

  const SimpleContentMediaItemSource({
    required this.description,
    required this.link,
    this.kind = FileKind.video,
    this.headers,
  });

  @override
  List<Object?> get props => [link, headers];
}

class SimpleMangaMediaItemSource extends MangaMediaItemSource {
  @override
  final String description;
  final List<String> pages;

  SimpleMangaMediaItemSource({
    required this.description,
    required this.pages,
  });
  @override
  FileKind get kind => FileKind.manga;

  @override
  int get pageNambers => pages.length;

  @override
  FutureOr<List<ImageProvider<Object>>> allPages() {
    return pages.map((e) => NetworkImage(e)).toList();
  }
}

typedef ContentItemMediaSourceLinkLoader = Future<Uri> Function();

// ignore: must_be_immutable
class AsyncContentMediaItemSource extends Equatable
    implements MediaFileItemSource {
  @override
  final FileKind kind;
  @override
  final String description;
  @override
  final Map<String, String>? headers;

  Uri? _linkLoader;

  final ContentItemMediaSourceLinkLoader linkLoader;

  @override
  Future<Uri> get link async => _linkLoader ??= await linkLoader();

  AsyncContentMediaItemSource({
    required this.description,
    required this.linkLoader,
    this.kind = FileKind.video,
    this.headers,
  });

  @override
  List<Object?> get props => [link, headers];
}

abstract class ContentSupplierBundle {
  Future<List<ContentSupplier>> get suppliers;
  Future<void> load() async {}
  void unload() {}
}

class ContentSuppliersException implements Exception {
  final String message;

  ContentSuppliersException(this.message);
}
