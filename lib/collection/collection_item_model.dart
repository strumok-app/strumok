import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'collection_item_model.g.dart';

enum MediaCollectionItemStatus { none, latter, inProgress, complete, onHold }

typedef ChangeCollectionCurrentItemCallback = void Function(int);

DateTime? _dateTimeFormMilli(dynamic value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return null;
}

int? _dateTimeToMilli(DateTime? value) {
  return value?.millisecondsSinceEpoch;
}

Map<String, dynamic> _mapPositions(Map<int, MediaItemPosition> positions) {
  return {
    for (final e in positions.entries) e.key.toString(): e.value.toJson(),
  };
}

@JsonSerializable()
// ignore: must_be_immutable
class MediaCollectionItem extends Equatable
    with ContentProgress
    implements ContentInfo {
  @override
  final String id;
  @override
  final String supplier;
  @override
  final String title;
  @override
  String? get secondaryTitle => null;
  @override
  final String image;
  @JsonKey(defaultValue: MediaType.video)
  final MediaType mediaType;
  @override
  int currentItem;
  @override
  String? currentSourceName;
  @override
  String? currentSubtitleName;
  @override
  // stupid json_serilizable can handle int keys properly!
  @JsonKey(toJson: _mapPositions)
  Map<int, MediaItemPosition> positions;

  final MediaCollectionItemStatus status;
  final int priority;

  @JsonKey(fromJson: _dateTimeFormMilli, toJson: _dateTimeToMilli)
  DateTime? lastSeen;

  MediaCollectionItem({
    required this.id,
    required this.supplier,
    required this.title,
    required this.image,
    required this.mediaType,
    this.currentItem = 0,
    this.currentSourceName,
    this.currentSubtitleName,
    this.positions = const {},
    this.status = MediaCollectionItemStatus.none,
    this.priority = 1,
    this.lastSeen,
  });

  factory MediaCollectionItem.fromContentDetails(ContentDetails details) =>
      MediaCollectionItem(
        id: details.id,
        supplier: details.supplier,
        image: details.image,
        title: details.title,
        mediaType: details.mediaType,
      );

  MediaCollectionItem copyWith({
    String? title,
    String? image,
    int? currentItem,
    ValueGetter<String?>? currentSourceName,
    ValueGetter<String?>? currentSubtitleName,
    Map<int, MediaItemPosition>? positions,
    MediaCollectionItemStatus? status,
    int? priority,
  }) {
    return MediaCollectionItem(
      id: id,
      supplier: supplier,
      title: title ?? this.title,
      image: image ?? this.image,
      mediaType: mediaType,
      currentItem: currentItem ?? this.currentItem,
      currentSourceName: currentSourceName != null
          ? currentSourceName()
          : this.currentSourceName,
      currentSubtitleName: currentSubtitleName != null
          ? currentSubtitleName()
          : this.currentSubtitleName,
      positions: positions != null
          ? {...this.positions, ...positions}
          : this.positions,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      lastSeen: lastSeen,
    );
  }

  factory MediaCollectionItem.fromJson(Map<String, dynamic> json) =>
      _$MediaCollectionItemFromJson(json);

  Map<String, dynamic> toJson() => _$MediaCollectionItemToJson(this);

  @override
  List<Object?> get props => [
    id,
    supplier,
    status,
    priority,
    currentItem,
    currentPosition,
    currentSourceName,
    currentSubtitleName,
  ];
}

@immutable
@JsonSerializable()
class MediaItemPosition extends Equatable {
  final int position;
  final int length;

  const MediaItemPosition({required this.position, required this.length});

  double get progress => length != 0 ? (position + 1) / length : 0;

  MediaItemPosition copyWith({int? position, int? length}) {
    return MediaItemPosition(
      position: position ?? this.position,
      length: length ?? this.length,
    );
  }

  static MediaItemPosition zero = const MediaItemPosition(
    position: 0,
    length: 0,
  );

  factory MediaItemPosition.fromJson(Map<String, dynamic> json) =>
      _$MediaItemPositionFromJson(json);

  Map<String, dynamic> toJson() => _$MediaItemPositionToJson(this);

  @override
  List<Object?> get props => [position, length];
}

mixin ContentProgress {
  String get id;
  String get supplier;

  int get currentItem;
  String? get currentSourceName;
  String? get currentSubtitleName;

  Map<int, MediaItemPosition> get positions;

  int get currentPosition => positions[currentItem]?.position ?? 0;

  MediaItemPosition get currentMediaItemPosition =>
      positions[currentItem] ?? MediaItemPosition.zero;
}
