import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/app_localizations.dart';

class OfflineStorageDirectorySelector extends ConsumerWidget {
  const OfflineStorageDirectorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dir = ref.watch(offlineStorageDirectoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.settingsDownloadsDirectory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 4),
        Row(
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
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            if (dir != null)
              IconButton(
                onPressed: () {
                  ref
                      .read(offlineStorageDirectoryProvider.notifier)
                      .select(null);
                },
                icon: Icon(Symbols.reset_settings),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                final path = await getDirectoryPath(canCreateDirectories: true);
                if (path != null && path.isNotEmpty) {
                  ref
                      .read(offlineStorageDirectoryProvider.notifier)
                      .select(path);
                }
              },
              child: Text(AppLocalizations.of(context)!.settingsSelect),
            ),
          ],
        ),
      ],
    );
  }
}
