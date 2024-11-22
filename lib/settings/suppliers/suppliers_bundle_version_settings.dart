import 'package:strumok/app_localizations.dart';
import 'package:strumok/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:strumok/settings/suppliers/suppliers_bundle_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuppliersBundleVersionSettings extends ConsumerWidget {
  const SuppliersBundleVersionSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedBundle = ref.watch(installedSupplierBundleInfoProvider);

    return installedBundle.maybeWhen(
      data: (installed) => installed == null
          ? const _SuppliersBundleInstall()
          : _SuppliersBundleUpdate(installedBundle: installed),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SuppliersBundleInstall extends ConsumerWidget {
  const _SuppliersBundleInstall();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestBundle = ref.watch(latestSupplierBundleInfoProvider);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        latestBundle.when(
          data: (info) {
            if (info == null) {
              return const SizedBox.shrink();
            }

            return SuppliersBundleDownloadButton(
              info: info,
              label: Text(AppLocalizations.of(context)!.install),
            );
          },
          loading: () => const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (Object error, StackTrace stackTrace) =>
              Text(error.toString()),
        ),
      ],
    );
  }
}

class _SuppliersBundleUpdate extends ConsumerWidget {
  final FFISupplierBundleInfo installedBundle;

  const _SuppliersBundleUpdate({required this.installedBundle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestBundle = ref.watch(latestSupplierBundleInfoProvider);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(installedBundle.version),
        const Spacer(),
        latestBundle.when(
          data: (data) {
            if (data == null) {
              return const SizedBox.shrink();
            }

            return renderUpdateButton(
              context,
              ref,
              data,
              installedBundle.version != data.version,
            );
          },
          skipLoadingOnRefresh: false,
          loading: () => FilledButton.tonalIcon(
            icon: const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator.adaptive(),
            ),
            onPressed: null,
            label: Text(AppLocalizations.of(context)!.settingsCheckForUpdate),
          ),
          error: (error, stackTrace) => Text(error.toString()),
        )
      ],
    );
  }

  Widget renderUpdateButton(
    BuildContext context,
    WidgetRef ref,
    FFISupplierBundleInfo latestInfo,
    bool hasNewVersion,
  ) {
    if (hasNewVersion) {
      return SuppliersBundleDownloadButton(
        info: latestInfo,
        label: Text(AppLocalizations.of(context)!
            .settingsDownloadUpdate(latestInfo.version)),
      );
    }

    return FilledButton.tonal(
      onPressed: () => ref.refresh(latestSupplierBundleInfoProvider),
      child: Text(AppLocalizations.of(context)!.settingsCheckForUpdate),
    );
  }
}

class SuppliersBundleDownloadButton extends ConsumerWidget {
  final FFISupplierBundleInfo info;
  final Widget label;

  const SuppliersBundleDownloadButton({
    super.key,
    required this.info,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(suppliersBundleDownloadProvider);

    return state.downloading
        ? FilledButton.tonalIcon(
            icon: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator.adaptive(
                value: state.progress == 0 ? null : state.progress,
              ),
            ),
            onPressed: null,
            label: label,
          )
        : FilledButton(
            onPressed: () {
              ref.read(suppliersBundleDownloadProvider.notifier).download(info);
            },
            child: label,
          );
  }
}
