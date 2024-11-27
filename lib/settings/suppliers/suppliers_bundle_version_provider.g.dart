// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_bundle_version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$installedSupplierBundleInfoHash() =>
    r'743b78551adec3feb4ba4645425450b87905b6aa';

/// See also [installedSupplierBundleInfo].
@ProviderFor(installedSupplierBundleInfo)
final installedSupplierBundleInfoProvider =
    AutoDisposeFutureProvider<FFISupplierBundleInfo?>.internal(
  installedSupplierBundleInfo,
  name: r'installedSupplierBundleInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$installedSupplierBundleInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InstalledSupplierBundleInfoRef
    = AutoDisposeFutureProviderRef<FFISupplierBundleInfo?>;
String _$latestSupplierBundleInfoHash() =>
    r'bc5618de31d90ff6ccbf0f3ac61a517f802aa333';

/// See also [latestSupplierBundleInfo].
@ProviderFor(latestSupplierBundleInfo)
final latestSupplierBundleInfoProvider =
    AutoDisposeFutureProvider<FFISupplierBundleInfo?>.internal(
  latestSupplierBundleInfo,
  name: r'latestSupplierBundleInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestSupplierBundleInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LatestSupplierBundleInfoRef
    = AutoDisposeFutureProviderRef<FFISupplierBundleInfo?>;
String _$suppliersBundleDownloadHash() =>
    r'8462fc5d59e101d62d8c8f028634b7b8272e7301';

/// See also [SuppliersBundleDownload].
@ProviderFor(SuppliersBundleDownload)
final suppliersBundleDownloadProvider =
    NotifierProvider<SuppliersBundleDownload, DownloadState>.internal(
  SuppliersBundleDownload.new,
  name: r'suppliersBundleDownloadProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$suppliersBundleDownloadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SuppliersBundleDownload = Notifier<DownloadState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
