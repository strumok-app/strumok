import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:strumok/settings/models.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/sem_ver.dart';
import 'package:strumok/utils/trace.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:path_provider/path_provider.dart';

part 'app_version_provider.g.dart';

@Riverpod(keepAlive: true)
FutureOr<SemVer> currentAppVersion(Ref ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return SemVer.fromString(packageInfo.version);
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

  factory AppVersionDownloadAssets.fromJson(Map<String, dynamic> json) => _$AppVersionDownloadAssetsFromJson(json);
}

@JsonSerializable(createToJson: false)
class LatestAppVersionInfo {
  final String name;
  final List<AppVersionDownloadAssets> assets;
  @JsonKey(includeFromJson: true)
  final SemVer version;

  LatestAppVersionInfo({
    required this.name,
    required this.assets,
  }) : version = SemVer.fromString(name);

  factory LatestAppVersionInfo.fromJson(Map<String, dynamic> json) => _$LatestAppVersionInfoFromJson(json);
}

@riverpod
FutureOr<LatestAppVersionInfo?> latestAppVersionInfo(Ref ref) async {
  try {
    const appVersionCheckURL = String.fromEnvironment("APP_VERSION_CHECK_URL");
    final res = await Client().get(Uri.parse(appVersionCheckURL));

    return LatestAppVersionInfo.fromJson(json.decode(res.body));
  } catch (e) {
    traceError(error: e, message: "fail to load lattest app version info");
    return null;
  }
}

@Riverpod(keepAlive: true)
class AppDownload extends _$AppDownload {
  @override
  DownloadState build() {
    return DownloadState.create();
  }

  void download(LatestAppVersionInfo info) async {
    AppVersionDownloadAssets? asset;

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;

      if (deviceInfo.supportedAbis.contains("arm64-v8a")) {
        asset = info.assets.where((a) => a.name.contains("app-arm64-v8a-release.apk")).firstOrNull;
      } else if (deviceInfo.supportedAbis.contains("armeabi-v7a")) {
        asset = info.assets.where((a) => a.name.contains("app-armeabi-v7a-release.apk")).firstOrNull;
      } else {
        asset = info.assets.where((a) => a.name.contains("app-release.apk")).firstOrNull;
      }

      if (asset != null) {
        _downloadAndInstallApk(info, asset);
        return;
      }
    }

    if (Platform.isLinux) {
      asset = info.assets.where((a) => a.name.contains("linux")).firstOrNull;
    } else if (Platform.isWindows) {
      asset = info.assets.where((a) => a.name.contains(".exe")).firstOrNull;
    }

    if (asset == null) {
      state = state.fail("Platform not supported");
      return;
    }

    launchUrlString(asset.browserDownloadUrl);
  }

  void _downloadAndInstallApk(
    LatestAppVersionInfo info,
    AppVersionDownloadAssets asset,
  ) async {
    state = state.start();

    final tmpDir = await getApplicationCacheDirectory();

    final installDirPath = "${tmpDir.path}${Platform.pathSeparator}install${Platform.pathSeparator}";
    final installDir = await Directory(installDirPath).create(recursive: true);

    final fileName = "${info.version}.apk";
    final filePath = "$installDirPath$fileName";

    // cleanup prev versions
    final files = await installDir.list().toList();

    for (var file in files) {
      if (file.path != filePath) {
        await file.delete();
      }
    }

    logger.i("App download path: $filePath");

    final task = DownloadManager().download(FileDownloadRequest(
      "app_download",
      asset.browserDownloadUrl,
      filePath,
    ));

    task.progress.addListener(() {
      state = state.updateProgress(task.progress.value);
    });
    task.status.addListener(() async {
      if (task.status.value == DownloadStatus.failed) {
        state = state.fail("Download failed");
        logger.i("New app version donwload failed");
      }
    });

    await task.whenDownloadComplete();

    logger.i("New app version donwload success");

    const installApk = MethodChannel('install_apk');

    try {
      await installApk.invokeMethod<bool>('installApk', {'filePath': filePath});
    } catch (e) {
      traceError(error: e, message: "new app vetsion installation failed");
      state.fail(e.toString());
    }

    state = state.done();
  }
}
