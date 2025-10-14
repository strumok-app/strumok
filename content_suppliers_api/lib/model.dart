import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum ContentType { movie, anime, cartoon, series, manga }

enum ContentLanguage {
  en("EN"),
  uk("UK"),
  ja("JA");

  final String label;

  const ContentLanguage(this.label);
}

enum MediaType { video, manga }

abstract class ContentSupplier {
  String get name;
  Set<String> get channels => const {};
  Set<String> get defaultChannels => const {};
  Set<ContentType> get supportedTypes => const {};
  Set<ContentLanguage> get supportedLanguages => const {};
  Future<List<ContentInfo>> search(String query, {int page = 0}) async =>
      const [];

  Future<List<ContentInfo>> loadChannel(String channel, {int page = 0}) async =>
      const [];
  Future<ContentDetails?> detailsById(
    String id,
    Set<ContentLanguage> langs,
  ) async => null;
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
  Map<String, String>? get headers;
}

abstract interface class MediaFileItemSource extends ContentMediaItemSource {
  FutureOr<Uri> get link;
}

abstract interface class MangaMediaItemSource extends ContentMediaItemSource {
  FutureOr<List<String>> get pages;
}

abstract interface class ContentDetails extends ContentInfo {
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
  final String? secondaryTitle;
  @override
  final String image;
  @override
  final String description;
  @override
  @JsonKey(defaultValue: [])
  final List<String> additionalInfo;
  @override
  @JsonKey(defaultValue: [], fromJson: ContentSearchResult.fromJsonList)
  final List<ContentInfo> similar;
  @override
  MediaType get mediaType => MediaType.video;
  @override
  FutureOr<Iterable<ContentMediaItem>> get mediaItems => const [];

  const AbstractContentDetails({
    required this.id,
    required this.supplier,
    required this.title,
    required this.secondaryTitle,
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
    secondaryTitle,
    image,
    description,
    additionalInfo,
    similar,
  ];
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

abstract class ContentSupplierBundle {
  Future<List<ContentSupplier>> get suppliers;
  Future<void> load() async {}
  void unload() {}
}

class ContentSuppliersException implements Exception {
  final String message;

  ContentSuppliersException(this.message);

  @override
  String toString() {
    return "ContentSuppliersException: $message";
  }
}
