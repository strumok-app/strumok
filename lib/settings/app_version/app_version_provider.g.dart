// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionDownloadAssets _$AppVersionDownloadAssetsFromJson(
        Map<String, dynamic> json) =>
    AppVersionDownloadAssets(
      browserDownloadUrl: json['browser_download_url'] as String,
      name: json['name'] as String,
    );

LatestAppVersionInfo _$LatestAppVersionInfoFromJson(
        Map<String, dynamic> json) =>
    LatestAppVersionInfo(
      name: json['name'] as String,
      assets: (json['assets'] as List<dynamic>)
          .map((e) =>
              AppVersionDownloadAssets.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentAppVersionHash() => r'b9decd7018b899e50f980ac99dd815d6a284f8ba';

/// See also [currentAppVersion].
@ProviderFor(currentAppVersion)
final currentAppVersionProvider = FutureProvider<String>.internal(
  currentAppVersion,
  name: r'currentAppVersionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAppVersionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentAppVersionRef = FutureProviderRef<String>;
String _$latestAppVersionInfoHash() =>
    r'149f57fc142307a4998937cd664b7db0ca7256b0';

/// See also [latestAppVersionInfo].
@ProviderFor(latestAppVersionInfo)
final latestAppVersionInfoProvider =
    AutoDisposeFutureProvider<LatestAppVersionInfo?>.internal(
  latestAppVersionInfo,
  name: r'latestAppVersionInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestAppVersionInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LatestAppVersionInfoRef
    = AutoDisposeFutureProviderRef<LatestAppVersionInfo?>;
String _$appDownloadHash() => r'affde9b2be6a1e09cc4f0ffd5d4238d21879be82';

/// See also [AppDownload].
@ProviderFor(AppDownload)
final appDownloadProvider =
    NotifierProvider<AppDownload, DownloadState>.internal(
  AppDownload.new,
  name: r'appDownloadProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDownloadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppDownload = Notifier<DownloadState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
