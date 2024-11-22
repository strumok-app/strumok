
import 'package:strumok/app_localizations.dart';
import 'package:strumok/settings/app_version/app_version_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppVersionSettings extends ConsumerWidget {
  const AppVersionSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVersion = ref.watch(currentAppVersionProvider);
    final latestVersionInfo = ref.watch(latestAppVersionInfoProvider);

    return currentVersion.maybeWhen(
      data: (current) => Row(mainAxisSize: MainAxisSize.max, children: [
        Text(current),
        const Spacer(),
        latestVersionInfo.when(
          data: (data) {
            return renderUpdateButton(
              context,
              ref,
              data,
              current,
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
          error: (Object error, StackTrace stackTrace) =>
              Text(error.toString()),
        )
      ]),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget renderUpdateButton(
    BuildContext context,
    WidgetRef ref,
    LatestAppVersionInfo? latestAppVersionInfo,
    String currentVersion,
  ) {
    if (latestAppVersionInfo != null && latestAppVersionInfo.version != currentVersion) {
      return AppDownloadButton(info: latestAppVersionInfo);
    }

    return FilledButton.tonal(
      onPressed: () => ref.refresh(latestAppVersionInfoProvider),
      child: Text(AppLocalizations.of(context)!.settingsCheckForUpdate),
    );
  }
}

class AppDownloadButton extends ConsumerWidget {
  final LatestAppVersionInfo info;

  const AppDownloadButton({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appDownloadProvider);
    final label = Text(
        AppLocalizations.of(context)!.settingsDownloadUpdate(info.version));

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
              ref.read(appDownloadProvider.notifier).download(info);
            },
            child: label,
          );
  }
}
