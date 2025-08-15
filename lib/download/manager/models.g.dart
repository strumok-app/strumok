// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadInfo _$DownloadInfoFromJson(Map<String, dynamic> json) => DownloadInfo(
  title: json['title'] as String,
  image: json['image'] as String,
);

Map<String, dynamic> _$DownloadInfoToJson(DownloadInfo instance) =>
    <String, dynamic>{'title': instance.title, 'image': instance.image};

VideoDownloadRequest _$VideoDownloadRequestFromJson(
  Map<String, dynamic> json,
) => VideoDownloadRequest(
  id: json['id'] as String,
  url: json['url'] as String,
  fileSrc: json['fileSrc'] as String,
  info: DownloadInfo.fromJson(json['info'] as Map<String, dynamic>),
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$VideoDownloadRequestToJson(
  VideoDownloadRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'fileSrc': instance.fileSrc,
  'headers': instance.headers,
  'info': instance.info.toJson(),
  'type': _$DownloadTypeEnumMap[instance.type]!,
};

const _$DownloadTypeEnumMap = {
  DownloadType.video: 'video',
  DownloadType.manga: 'manga',
  DownloadType.file: 'file',
};

MangaDownloadRequest _$MangaDownloadRequestFromJson(
  Map<String, dynamic> json,
) => MangaDownloadRequest(
  id: json['id'] as String,
  pages: (json['pages'] as List<dynamic>).map((e) => e as String).toList(),
  folder: json['folder'] as String,
  info: DownloadInfo.fromJson(json['info'] as Map<String, dynamic>),
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$MangaDownloadRequestToJson(
  MangaDownloadRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'pages': instance.pages,
  'folder': instance.folder,
  'headers': instance.headers,
  'info': instance.info.toJson(),
  'type': _$DownloadTypeEnumMap[instance.type]!,
};

FileDownloadRequest _$FileDownloadRequestFromJson(Map<String, dynamic> json) =>
    FileDownloadRequest(
      json['id'] as String,
      json['url'] as String,
      json['fileSrc'] as String,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$FileDownloadRequestToJson(
  FileDownloadRequest instance,
) => <String, dynamic>{
  'url': instance.url,
  'fileSrc': instance.fileSrc,
  'headers': instance.headers,
  'type': _$DownloadTypeEnumMap[instance.type]!,
  'id': instance.id,
};
