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

String _$currentAppVersionHash() => r'1b8be778347ea0923da209174409af1bdd9b6add';

/// See also [currentAppVersion].
@ProviderFor(currentAppVersion)
final currentAppVersionProvider = FutureProvider<SemVer>.internal(
  currentAppVersion,
  name: r'currentAppVersionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAppVersionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentAppVersionRef = FutureProviderRef<SemVer>;
String _$latestAppVersionInfoHash() =>
    r'ca751369e9e53d419f029fd2b87007323bbfde53';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestAppVersionInfoRef
    = AutoDisposeFutureProviderRef<LatestAppVersionInfo?>;
String _$appDownloadHash() => r'aa87e2e83fca84a146e5075fd91d596d85a51960';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
