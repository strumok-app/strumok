import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/collection/sync/collection_sync.dart';
import 'package:strumok/collection/sync/collection_sync_provider.dart';

class UserDialog extends StatelessWidget {
  final User user;

  const UserDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: user.picture != null ? NetworkImage(user.picture!) : null,
              ),
              title: Text(user.name!),
            ),
            const SyncButton(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.singOut),
              onTap: () {
                Navigator.of(context).pop();
                Auth.instance.singOut();
              },
            )
          ],
        ),
      ),
    );
  }
}

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(collectionSyncStatusProvider).valueOrNull ?? false;

    return ListTile(
      enabled: !syncStatus,
      leading: syncStatus
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(),
            )
          : const Icon(Icons.refresh),
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

        return;
      },
    );
  }
}
