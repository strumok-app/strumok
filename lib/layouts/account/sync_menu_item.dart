import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/collection/sync/collection_sync.dart';
import 'package:strumok/collection/sync/collection_sync_provider.dart';

class SyncMenuItem extends ConsumerWidget {
  const SyncMenuItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus =
        ref.watch(collectionSyncStatusProvider).valueOrNull ?? false;

    return ListTile(
      enabled: !syncStatus,
      leading:
          syncStatus
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              )
              : const Icon(Icons.refresh_rounded),
      title: Text(AppLocalizations.of(context)!.collectionSync),
      onTap: () async {
        await CollectionSync.instance.run();

        ref.invalidate(collectionItemProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.collectionSyncDone),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
}
