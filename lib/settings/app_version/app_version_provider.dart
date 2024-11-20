import 'dart:convert';

import 'package:strumok/app_secrets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart';
import 'package:strumok/utils/logger.dart';

part 'app_version_provider.g.dart';

@Riverpod(keepAlive: true)
FutureOr<String> currentAppVersion(CurrentAppVersionRef ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

@JsonSerializable(createToJson: false)
class AppVersionDownloadAssets {
  @JsonKey(name: "browser_download_url")
  final String browserDownloadUrl;
  final String name;

  AppVersionDownloadAssets({
    required this.browserDownloadUrl,
    required this.name,
  });

  factory AppVersionDownloadAssets.fromJson(Map<String, dynamic> json) =>
      _$AppVersionDownloadAssetsFromJson(json);
}

@JsonSerializable(createToJson: false)
class LatestAppVersionInfo {
  final String name;
  final List<AppVersionDownloadAssets> assets;

  String get version => name.substring(1);

  LatestAppVersionInfo({
    required this.name,
    required this.assets,
  });

  factory LatestAppVersionInfo.fromJson(Map<String, dynamic> json) =>
      _$LatestAppVersionInfoFromJson(json);
}

@riverpod
FutureOr<LatestAppVersionInfo?> latestAppVersionInfo(
    LatestAppVersionInfoRef ref) async {
  try {
    final appVersionCheckURL = AppSecrets.getString("appVersionCheckURL");
    final res = await Client().get(Uri.parse(appVersionCheckURL));

    return LatestAppVersionInfo.fromJson(json.decode(res.body));
  } catch (e) {
    logger.e("Failed to load lattest app version: $e");
    return null;
  }
}
