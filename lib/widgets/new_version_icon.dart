import 'package:strumok/settings/app_version/app_version_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_bundle_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/utils/sem_ver.dart';

part 'new_version_icon.g.dart';

@riverpod
bool hasNewVersion(Ref ref) {
  final currentAppVersion = ref.watch(currentAppVersionProvider).valueOrNull;
  final latestAppVersionInfo = ref.watch(latestAppVersionInfoProvider).valueOrNull;

  final installedSupplierBundleVersion = ref.watch(installedSupplierBundleInfoProvider).valueOrNull?.version;

  final latestSupplierBundleVersion = ref.watch(latestSupplierBundleInfoProvider).valueOrNull?.version ?? SemVer.zero;

  if (installedSupplierBundleVersion == null) {
    return true;
  }

  if (currentAppVersion == null || latestAppVersionInfo == null) {
    return false;
  }

  return latestAppVersionInfo.version.compareTo(currentAppVersion) > 0 ||
      latestSupplierBundleVersion.compareTo(installedSupplierBundleVersion) > 0;
}

class NewVersionIcon extends ConsumerWidget {
  final IconData icon;

  const NewVersionIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNewVersion = ref.watch(hasNewVersionProvider);

    if (hasNewVersion) {
      return Badge(child: Icon(icon));
    }

    return Icon(icon);
  }
}
