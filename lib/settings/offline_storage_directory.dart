import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/app_localizations.dart';

class OfflineStorageDirectorySelector extends ConsumerWidget {
  const OfflineStorageDirectorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dir = ref.watch(offlineStorageDirectoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Text(
            dir ??
                AppLocalizations.of(
                  context,
                )!.settingsOfflineStorageDirectoryNotSelected,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final path = await getDirectoryPath(canCreateDirectories: true);
            if (path != null && path.isNotEmpty) {
              ref.read(offlineStorageDirectoryProvider.notifier).select(path);
            }
          },
          child: Text(AppLocalizations.of(context)!.settingsSelect),
        ),
      ],
    );
  }
}
