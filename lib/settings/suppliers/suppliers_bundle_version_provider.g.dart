// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_bundle_version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(installedSupplierBundleInfo)
const installedSupplierBundleInfoProvider =
    InstalledSupplierBundleInfoProvider._();

final class InstalledSupplierBundleInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<FFISupplierBundleInfo?>,
          FFISupplierBundleInfo?,
          FutureOr<FFISupplierBundleInfo?>
        >
    with
        $FutureModifier<FFISupplierBundleInfo?>,
        $FutureProvider<FFISupplierBundleInfo?> {
  const InstalledSupplierBundleInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedSupplierBundleInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedSupplierBundleInfoHash();

  @$internal
  @override
  $FutureProviderElement<FFISupplierBundleInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FFISupplierBundleInfo?> create(Ref ref) {
    return installedSupplierBundleInfo(ref);
  }
}

String _$installedSupplierBundleInfoHash() =>
    r'b7378bcf1fe611ff83ec4c8662f80a3777377c9b';

@ProviderFor(latestSupplierBundleInfo)
const latestSupplierBundleInfoProvider = LatestSupplierBundleInfoProvider._();

final class LatestSupplierBundleInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<FFISupplierBundleInfo?>,
          FFISupplierBundleInfo?,
          FutureOr<FFISupplierBundleInfo?>
        >
    with
        $FutureModifier<FFISupplierBundleInfo?>,
        $FutureProvider<FFISupplierBundleInfo?> {
  const LatestSupplierBundleInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestSupplierBundleInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestSupplierBundleInfoHash();

  @$internal
  @override
  $FutureProviderElement<FFISupplierBundleInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FFISupplierBundleInfo?> create(Ref ref) {
    return latestSupplierBundleInfo(ref);
  }
}

String _$latestSupplierBundleInfoHash() =>
    r'b99b01b7a7f96a4e5f93f2f149d54951d393da78';

@ProviderFor(SuppliersBundleDownload)
const suppliersBundleDownloadProvider = SuppliersBundleDownloadProvider._();

final class SuppliersBundleDownloadProvider
    extends $NotifierProvider<SuppliersBundleDownload, DownloadState> {
  const SuppliersBundleDownloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suppliersBundleDownloadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suppliersBundleDownloadHash();

  @$internal
  @override
  SuppliersBundleDownload create() => SuppliersBundleDownload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadState>(value),
    );
  }
}

String _$suppliersBundleDownloadHash() =>
    r'1b8be1f4923906e595e8cc986889b3d25a9c550c';

abstract class _$SuppliersBundleDownload extends $Notifier<DownloadState> {
  DownloadState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DownloadState, DownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DownloadState, DownloadState>,
              DownloadState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
