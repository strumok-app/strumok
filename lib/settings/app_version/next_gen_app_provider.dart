import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/settings/app_version/app_version_provider.dart';
import 'package:strumok/settings/models.dart';
import 'package:strumok/utils/http.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/trace.dart';
import 'package:url_launcher/url_launcher.dart';

part 'next_gen_app_provider.g.dart';

const _platformAssetSuffix = {
  "android": ".apk",
  "windows": ".exe",
  "linux": ".tar.gz",
};

@JsonSerializable(createToJson: false)
class NextGenAppInfo {
  final String? name;
  @JsonKey(name: "tag_name")
  final String tagName;
  @JsonKey(name: "html_url")
  final String htmlUrl;
  @JsonKey(defaultValue: <AppVersionDownloadAssets>[])
  final List<AppVersionDownloadAssets> assets;

  NextGenAppInfo({
    required this.name,
    required this.tagName,
    required this.htmlUrl,
    this.assets = const [],
  });

  String get title => name?.isNotEmpty == true ? name! : tagName;

  /// Release asset to install on the given [operatingSystem]
  /// (as in [Platform.operatingSystem]).
  AppVersionDownloadAssets? assetFor(String operatingSystem) {
    final suffix = _platformAssetSuffix[operatingSystem];
    if (suffix == null) {
      return null;
    }

    return assets.where((a) => a.name.endsWith(suffix)).firstOrNull;
  }

  factory NextGenAppInfo.fromJson(Map<String, dynamic> json) =>
      _$NextGenAppInfoFromJson(json);
}

@riverpod
FutureOr<NextGenAppInfo?> nextGenAppInfo(Ref ref) async {
  const nextGenCheckURL = String.fromEnvironment("APP_NEXT_GEN_CHECK_URL");

  if (nextGenCheckURL.isEmpty) {
    return null;
  }

  try {
    final res = await appHttpClient.get(Uri.parse(nextGenCheckURL));
    return NextGenAppInfo.fromJson(json.decode(res.body));
  } catch (e) {
    traceError(error: e, message: "fail to load next gen app info");
    return null;
  }
}

@Riverpod(keepAlive: true)
class NextGenAppInstall extends _$NextGenAppInstall {
  @override
  DownloadState build() {
    return DownloadState.create();
  }

  Future<void> install(NextGenAppInfo info) async {
    if (state.downloading) {
      return;
    }

    final asset = info.assetFor(Platform.operatingSystem);

    if (!Platform.isAndroid || asset == null) {
      await launchUrl(Uri.parse(asset?.browserDownloadUrl ?? info.htmlUrl));
      state = state.done();
      return;
    }

    state = state.start();

    try {
      // Must match the FileProvider cache-path in android provider_paths.xml.
      final cacheDir = await getApplicationCacheDirectory();
      final installDir = Directory(
        "${cacheDir.path}${Platform.pathSeparator}install",
      );
      if (await installDir.exists()) {
        await installDir.delete(recursive: true);
      }
      await installDir.create(recursive: true);

      final filePath =
          "${installDir.path}${Platform.pathSeparator}${asset.name}";

      logger.info("Next gen app download path: $filePath");

      final task = DownloadManager().download(
        FileDownloadRequest(
          "next_gen_app_download",
          asset.browserDownloadUrl,
          filePath,
        ),
      );

      void onProgress() {
        state = state.updateProgress(task.progress.value);
      }

      task.progress.addListener(onProgress);
      final status = await task.whenDownloadComplete();
      task.progress.removeListener(onProgress);

      if (status != DownloadStatus.completed) {
        state = state.fail("Download ${status.name}");
        return;
      }

      const installApk = MethodChannel('install_apk');
      await installApk.invokeMethod<bool>('installApk', {'filePath': filePath});
      state = state.done();
    } catch (e) {
      traceError(error: e, message: "next gen app installation failed");
      state = state.fail(e.toString());
    }
  }
}
