import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:strumok/settings/suppliers/suppliers_bundle_version_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_bundle_version_settings.dart';

class VersionGuard extends ConsumerWidget {
  final Widget child;

  const VersionGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedBundle = ref.watch(installedSupplierBundleInfoProvider);

    return Scaffold(
      body: installedBundle.when(
        data: (info) => info != null ? child : _InstallSuppliersBundler(),
        error: (error, stackTrace) => _Error(error: AppLocalizations.of(context)!.ffiLibInstallationFailed),
        loading: () => _Loader(),
      ),
    );
  }
}

class _InstallSuppliersBundler extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lattestBundle = ref.watch(latestSupplierBundleInfoProvider);

    return lattestBundle.when(
      data: (info) => info == null
          ? _Error(error: AppLocalizations.of(context)!.ffiLibInstallationFailed)
          : _buildInstall(context, info),
      error: (error, stackTrace) => _Error(error: error.toString()),
      loading: () => _Loader(),
    );
  }

  Widget _buildInstall(BuildContext context, FFISupplierBundleInfo info) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.ffiLibNotInstalled),
          const SizedBox(height: 8),
          SuppliersBundleDownloadButton(
            autofocus: true,
            info: info,
            label: Text(AppLocalizations.of(context)!.install),
          ),
        ],
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(error));
  }
}
