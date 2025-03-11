// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ffi_supplier_bundle_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FFISupplierBundleInfo _$FFISupplierBundleInfoFromJson(
  Map<String, dynamic> json,
) => FFISupplierBundleInfo(
  name: json['name'] as String,
  version: SemVer.fromJson(json['version']),
  metadataUrl: json['metadataUrl'] as String,
  downloadUrl: Map<String, String>.from(json['downloadUrl'] as Map),
);

Map<String, dynamic> _$FFISupplierBundleInfoToJson(
  FFISupplierBundleInfo instance,
) => <String, dynamic>{
  'name': instance.name,
  'version': instance.version,
  'metadataUrl': instance.metadataUrl,
  'downloadUrl': instance.downloadUrl,
};
