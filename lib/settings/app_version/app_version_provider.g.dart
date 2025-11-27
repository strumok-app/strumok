// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionDownloadAssets _$AppVersionDownloadAssetsFromJson(
  Map<String, dynamic> json,
) => AppVersionDownloadAssets(
  browserDownloadUrl: json['browser_download_url'] as String,
  name: json['name'] as String,
);

LatestAppVersionInfo _$LatestAppVersionInfoFromJson(
  Map<String, dynamic> json,
) => LatestAppVersionInfo(
  name: json['name'] as String,
  assets: (json['assets'] as List<dynamic>)
      .map((e) => AppVersionDownloadAssets.fromJson(e as Map<String, dynamic>))
      .toList(),
);

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentAppVersion)
const currentAppVersionProvider = CurrentAppVersionProvider._();

final class CurrentAppVersionProvider
    extends $FunctionalProvider<AsyncValue<SemVer>, SemVer, FutureOr<SemVer>>
    with $FutureModifier<SemVer>, $FutureProvider<SemVer> {
  const CurrentAppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAppVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAppVersionHash();

  @$internal
  @override
  $FutureProviderElement<SemVer> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SemVer> create(Ref ref) {
    return currentAppVersion(ref);
  }
}

String _$currentAppVersionHash() => r'1b8be778347ea0923da209174409af1bdd9b6add';

@ProviderFor(latestAppVersionInfo)
const latestAppVersionInfoProvider = LatestAppVersionInfoProvider._();

final class LatestAppVersionInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<LatestAppVersionInfo?>,
          LatestAppVersionInfo?,
          FutureOr<LatestAppVersionInfo?>
        >
    with
        $FutureModifier<LatestAppVersionInfo?>,
        $FutureProvider<LatestAppVersionInfo?> {
  const LatestAppVersionInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestAppVersionInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestAppVersionInfoHash();

  @$internal
  @override
  $FutureProviderElement<LatestAppVersionInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LatestAppVersionInfo?> create(Ref ref) {
    return latestAppVersionInfo(ref);
  }
}

String _$latestAppVersionInfoHash() =>
    r'e75cffaac55d5f35152d7cbfc17417f0a7e415dc';

@ProviderFor(AppDownload)
const appDownloadProvider = AppDownloadProvider._();

final class AppDownloadProvider
    extends $NotifierProvider<AppDownload, DownloadState> {
  const AppDownloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDownloadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDownloadHash();

  @$internal
  @override
  AppDownload create() => AppDownload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadState>(value),
    );
  }
}

String _$appDownloadHash() => r'fa6a375a08d2219949cfef13d70bdb7fa9e75f98';

abstract class _$AppDownload extends $Notifier<DownloadState> {
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
