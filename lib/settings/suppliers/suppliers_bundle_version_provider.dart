// ignore_for_file: unused_result

import 'dart:convert';
import 'dart:io';

import 'package:strumok/app_preferences.dart';
import 'package:strumok/app_secrets.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:strumok/content_suppliers/ffi_suppliers_bundle_storage.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suppliers_bundle_version_provider.g.dart';

@riverpod
Future<FFISupplierBundleInfo?> installedSupplierBundleInfo(
  InstalledSupplierBundleInfoRef ref,
) async {
  final info = AppPreferences.ffiSupplierBundleInfo;

  if (info != null) {
    final installed =
        await FFISuppliersBundleStorage.instance.isInstalled(info);

    if (!installed) {
      return null;
    }
  }

  return info;
}

@riverpod
FutureOr<FFISupplierBundleInfo?> latestSupplierBundleInfo(
  LatestSupplierBundleInfoRef ref,
) async {
  try {
    final latestVersionUrl = AppSecrets.getString("ffiLibVersionCheckURL");
    final res = await Client().get(Uri.parse(latestVersionUrl));
    return FFISupplierBundleInfo.fromJson(json.decode(res.body));
  } catch (e) {
    logger.e("Failed to load lattest bundle version: $e");
    return null;
  }
}

class SuppliersBundleDownloadState {
  final FFISupplierBundleInfo info;
  final bool downloading;
  final double progress;
  final String? error;

  SuppliersBundleDownloadState({
    required this.info,
    required this.downloading,
    required this.progress,
    this.error,
  });

  factory SuppliersBundleDownloadState.create(FFISupplierBundleInfo info) =>
      SuppliersBundleDownloadState(
        info: info,
        downloading: false,
        progress: 0.0,
      );

  SuppliersBundleDownloadState updateProgress(double progress) {
    return SuppliersBundleDownloadState(
      info: info,
      downloading: downloading,
      progress: progress,
    );
  }

  SuppliersBundleDownloadState start() {
    return SuppliersBundleDownloadState(
      info: info,
      downloading: true,
      progress: 0.0,
    );
  }

  SuppliersBundleDownloadState fail(String error) {
    return SuppliersBundleDownloadState(
      info: info,
      downloading: downloading,
      progress: progress,
      error: error,
    );
  }

  SuppliersBundleDownloadState done() {
    return SuppliersBundleDownloadState(
      info: info,
      downloading: false,
      progress: 1.0,
    );
  }
}

final downloadManager = DownloadManager();

@Riverpod(keepAlive: true)
class SuppliersBundleDownload extends _$SuppliersBundleDownload {
  @override
  SuppliersBundleDownloadState build(FFISupplierBundleInfo info) {
    return SuppliersBundleDownloadState.create(info);
  }

  void download() async {
    state = state.start();

    final libPath = FFISuppliersBundleStorage.instance.getLibFilePath(info);
    final url = await _downloadUrl(info);

    if (url == null) {
      state = state.fail("platform not supported");
      return;
    }

    final task = await downloadManager.addDownload(url, libPath);
    if (task != null) {
      task.progress.addListener(() {
        state = state.updateProgress(task.progress.value);
      });
      task.status.addListener(() async {
        if (task.status.value == DownloadStatus.completed) {
          logger.i("New FFI bundle version donwloaded");
          // reload bundles
          await ContentSuppliers.instance.reload(info.libName);
          // save info
          AppPreferences.ffiSupplierBundleInfo = info;
          // refresh providers
          ref.refresh(installedSupplierBundleInfoProvider);
          ref.refresh(suppliersSettingsProvider);
          // cleanup old versions
          FFISuppliersBundleStorage.instance.cleanup(info);
        } else if (task.status.value == DownloadStatus.failed) {
          state = state.fail("Download failed");
          logger.i("New FFI bundle version donwload failed");
        }
      });
    }
  }

  Future<String?> _downloadUrl(FFISupplierBundleInfo info) async {
    if (Platform.isLinux) {
      return info.downloadUrl["linux"];
    } else if (Platform.isWindows) {
      return info.downloadUrl["windows"];
    } else {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;

      if (deviceInfo.supportedAbis.contains("arm64-v8a")) {
        return info.downloadUrl["arm64-v8a"];
      } else if (deviceInfo.supportedAbis.contains("armeabi-v7a")) {
        return info.downloadUrl["armeabi-v7a"];
      }
    }

    return null;
  }
}
