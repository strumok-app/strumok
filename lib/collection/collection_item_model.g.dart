// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaCollectionItem _$MediaCollectionItemFromJson(Map<String, dynamic> json) =>
    MediaCollectionItem(
      id: json['id'] as String,
      supplier: json['supplier'] as String,
      title: json['title'] as String,
      image: json['image'] as String,
      mediaType:
          $enumDecodeNullable(_$MediaTypeEnumMap, json['mediaType']) ??
          MediaType.video,
      currentItem: (json['currentItem'] as num?)?.toInt() ?? 0,
      currentSourceName: json['currentSourceName'] as String?,
      currentSubtitleName: json['currentSubtitleName'] as String?,
      positions:
          (json['positions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              int.parse(k),
              MediaItemPosition.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
          const {},
      status:
          $enumDecodeNullable(
            _$MediaCollectionItemStatusEnumMap,
            json['status'],
          ) ??
          MediaCollectionItemStatus.none,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      lastSeen: _dateTimeFormMilli(json['lastSeen']),
    );

Map<String, dynamic> _$MediaCollectionItemToJson(
  MediaCollectionItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'supplier': instance.supplier,
  'title': instance.title,
  'image': instance.image,
  'mediaType': _$MediaTypeEnumMap[instance.mediaType]!,
  'currentItem': instance.currentItem,
  'currentSourceName': instance.currentSourceName,
  'currentSubtitleName': instance.currentSubtitleName,
  'positions': _mapPositions(instance.positions),
  'status': _$MediaCollectionItemStatusEnumMap[instance.status]!,
  'priority': instance.priority,
  'lastSeen': _dateTimeToMilli(instance.lastSeen),
};

const _$MediaTypeEnumMap = {MediaType.video: 'video', MediaType.manga: 'manga'};

const _$MediaCollectionItemStatusEnumMap = {
  MediaCollectionItemStatus.none: 'none',
  MediaCollectionItemStatus.latter: 'latter',
  MediaCollectionItemStatus.inProgress: 'inProgress',
  MediaCollectionItemStatus.complete: 'complete',
  MediaCollectionItemStatus.onHold: 'onHold',
};

MediaItemPosition _$MediaItemPositionFromJson(Map<String, dynamic> json) =>
    MediaItemPosition(
      position: (json['position'] as num).toInt(),
      length: (json['length'] as num).toInt(),
    );

Map<String, dynamic> _$MediaItemPositionToJson(MediaItemPosition instance) =>
    <String, dynamic>{'position': instance.position, 'length': instance.length};
