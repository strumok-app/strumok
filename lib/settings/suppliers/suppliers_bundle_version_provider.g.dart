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
    r'29c7948ce4cc139e260d976918a727dc22cd0123';

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
    r'e62e483b5a2491a47c3624c3bb9da8013230ac2d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SuppliersBundleDownload
    extends BuildlessNotifier<SuppliersBundleDownloadState> {
  late final FFISupplierBundleInfo info;

  SuppliersBundleDownloadState build(
    FFISupplierBundleInfo info,
  );
}

/// See also [SuppliersBundleDownload].
@ProviderFor(SuppliersBundleDownload)
const suppliersBundleDownloadProvider = SuppliersBundleDownloadFamily();

/// See also [SuppliersBundleDownload].
class SuppliersBundleDownloadFamily
    extends Family<SuppliersBundleDownloadState> {
  /// See also [SuppliersBundleDownload].
  const SuppliersBundleDownloadFamily();

  /// See also [SuppliersBundleDownload].
  SuppliersBundleDownloadProvider call(
    FFISupplierBundleInfo info,
  ) {
    return SuppliersBundleDownloadProvider(
      info,
    );
  }

  @override
  SuppliersBundleDownloadProvider getProviderOverride(
    covariant SuppliersBundleDownloadProvider provider,
  ) {
    return call(
      provider.info,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'suppliersBundleDownloadProvider';
}

/// See also [SuppliersBundleDownload].
class SuppliersBundleDownloadProvider extends NotifierProviderImpl<
    SuppliersBundleDownload, SuppliersBundleDownloadState> {
  /// See also [SuppliersBundleDownload].
  SuppliersBundleDownloadProvider(
    FFISupplierBundleInfo info,
  ) : this._internal(
          () => SuppliersBundleDownload()..info = info,
          from: suppliersBundleDownloadProvider,
          name: r'suppliersBundleDownloadProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$suppliersBundleDownloadHash,
          dependencies: SuppliersBundleDownloadFamily._dependencies,
          allTransitiveDependencies:
              SuppliersBundleDownloadFamily._allTransitiveDependencies,
          info: info,
        );

  SuppliersBundleDownloadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.info,
  }) : super.internal();

  final FFISupplierBundleInfo info;

  @override
  SuppliersBundleDownloadState runNotifierBuild(
    covariant SuppliersBundleDownload notifier,
  ) {
    return notifier.build(
      info,
    );
  }

  @override
  Override overrideWith(SuppliersBundleDownload Function() create) {
    return ProviderOverride(
      origin: this,
      override: SuppliersBundleDownloadProvider._internal(
        () => create()..info = info,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        info: info,
      ),
    );
  }

  @override
  NotifierProviderElement<SuppliersBundleDownload, SuppliersBundleDownloadState>
      createElement() {
    return _SuppliersBundleDownloadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SuppliersBundleDownloadProvider && other.info == info;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, info.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SuppliersBundleDownloadRef
    on NotifierProviderRef<SuppliersBundleDownloadState> {
  /// The parameter `info` of this provider.
  FFISupplierBundleInfo get info;
}

class _SuppliersBundleDownloadProviderElement extends NotifierProviderElement<
    SuppliersBundleDownload,
    SuppliersBundleDownloadState> with SuppliersBundleDownloadRef {
  _SuppliersBundleDownloadProviderElement(super.provider);

  @override
  FFISupplierBundleInfo get info =>
      (origin as SuppliersBundleDownloadProvider).info;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
