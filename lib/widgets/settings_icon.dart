import 'package:strumok/settings/app_version/app_version_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_bundle_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/utils/sem_ver.dart';

part 'settings_icon.g.dart';

@riverpod
bool hasNewVersion(HasNewVersionRef ref) {
  final currentAppVersion = ref.watch(currentAppVersionProvider).valueOrNull;
  final latestAppVersionInfo =
      ref.watch(latestAppVersionInfoProvider).valueOrNull;

  final installedSupplierBundleVersion =
      ref.watch(installedSupplierBundleInfoProvider).valueOrNull?.version;

  final latestSupplierBundleVersion =
      ref.watch(latestSupplierBundleInfoProvider).valueOrNull?.version ??
          SemVer.zero;

  if (installedSupplierBundleVersion == null) {
    return true;
  }

  if (currentAppVersion == null || latestAppVersionInfo == null) {
    return false;
  }

  return latestAppVersionInfo.version.compareTo(currentAppVersion) > 0 ||
      latestSupplierBundleVersion.compareTo(installedSupplierBundleVersion) > 0;
}

class SettingsIcon extends ConsumerWidget {
  const SettingsIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNewVersion = ref.watch(hasNewVersionProvider);

    if (hasNewVersion) {
      return const Badge(child: Icon(Icons.settings));
    }

    return const Icon(Icons.settings);
  }
}
