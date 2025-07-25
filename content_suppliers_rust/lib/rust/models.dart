// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.10.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;
part 'models.freezed.dart';

class ContentDetails {
  final String title;
  final String? originalTitle;
  final String image;
  final String description;
  final MediaType mediaType;
  final List<String> additionalInfo;
  final List<ContentInfo> similar;
  final List<ContentMediaItem>? mediaItems;
  final List<String> params;

  const ContentDetails({
    required this.title,
    this.originalTitle,
    required this.image,
    required this.description,
    required this.mediaType,
    required this.additionalInfo,
    required this.similar,
    this.mediaItems,
    required this.params,
  });

  @override
  int get hashCode =>
      title.hashCode ^
      originalTitle.hashCode ^
      image.hashCode ^
      description.hashCode ^
      mediaType.hashCode ^
      additionalInfo.hashCode ^
      similar.hashCode ^
      mediaItems.hashCode ^
      params.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentDetails &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          originalTitle == other.originalTitle &&
          image == other.image &&
          description == other.description &&
          mediaType == other.mediaType &&
          additionalInfo == other.additionalInfo &&
          similar == other.similar &&
          mediaItems == other.mediaItems &&
          params == other.params;
}

class ContentInfo {
  final String id;
  final String title;
  final String? secondaryTitle;
  final String image;

  const ContentInfo({
    required this.id,
    required this.title,
    this.secondaryTitle,
    required this.image,
  });

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ secondaryTitle.hashCode ^ image.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          secondaryTitle == other.secondaryTitle &&
          image == other.image;
}

class ContentMediaItem {
  final String title;
  final String? section;
  final String? image;
  final List<ContentMediaItemSource>? sources;
  final List<String> params;

  const ContentMediaItem({
    required this.title,
    this.section,
    this.image,
    this.sources,
    required this.params,
  });

  @override
  int get hashCode =>
      title.hashCode ^
      section.hashCode ^
      image.hashCode ^
      sources.hashCode ^
      params.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentMediaItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          section == other.section &&
          image == other.image &&
          sources == other.sources &&
          params == other.params;
}

@freezed
sealed class ContentMediaItemSource with _$ContentMediaItemSource {
  const ContentMediaItemSource._();

  const factory ContentMediaItemSource.video({
    required String link,
    required String description,
    Map<String, String>? headers,
  }) = ContentMediaItemSource_Video;
  const factory ContentMediaItemSource.subtitle({
    required String link,
    required String description,
    Map<String, String>? headers,
  }) = ContentMediaItemSource_Subtitle;
  const factory ContentMediaItemSource.manga({
    required String description,
    Map<String, String>? headers,
    List<String>? pages,
    required List<String> params,
  }) = ContentMediaItemSource_Manga;
}

enum ContentType { movie, anime, cartoon, series, manga }

enum MediaType { video, manga }
