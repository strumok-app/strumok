// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_bundle_version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$installedSupplierBundleInfoHash() =>
    r'b7378bcf1fe611ff83ec4c8662f80a3777377c9b';

/// See also [installedSupplierBundleInfo].
@ProviderFor(installedSupplierBundleInfo)
final installedSupplierBundleInfoProvider =
    AutoDisposeFutureProvider<FFISupplierBundleInfo?>.internal(
      installedSupplierBundleInfo,
      name: r'installedSupplierBundleInfoProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$installedSupplierBundleInfoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InstalledSupplierBundleInfoRef =
    AutoDisposeFutureProviderRef<FFISupplierBundleInfo?>;
String _$latestSupplierBundleInfoHash() =>
    r'b99b01b7a7f96a4e5f93f2f149d54951d393da78';

/// See also [latestSupplierBundleInfo].
@ProviderFor(latestSupplierBundleInfo)
final latestSupplierBundleInfoProvider =
    AutoDisposeFutureProvider<FFISupplierBundleInfo?>.internal(
      latestSupplierBundleInfo,
      name: r'latestSupplierBundleInfoProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$latestSupplierBundleInfoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestSupplierBundleInfoRef =
    AutoDisposeFutureProviderRef<FFISupplierBundleInfo?>;
String _$suppliersBundleDownloadHash() =>
    r'8bd26f51de7a35875298766c9ad4fc2223f3ec04';

/// See also [SuppliersBundleDownload].
@ProviderFor(SuppliersBundleDownload)
final suppliersBundleDownloadProvider =
    NotifierProvider<SuppliersBundleDownload, DownloadState>.internal(
      SuppliersBundleDownload.new,
      name: r'suppliersBundleDownloadProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$suppliersBundleDownloadHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SuppliersBundleDownload = Notifier<DownloadState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
