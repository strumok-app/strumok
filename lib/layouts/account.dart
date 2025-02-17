import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/auth/auth_provider.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/collection/sync/collection_sync.dart';
import 'package:strumok/collection/sync/collection_sync_provider.dart';
import 'package:strumok/widgets/new_version_icon.dart';

class AccountMenuIcon extends StatelessWidget {
  const AccountMenuIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 56,
      child: IconButton(
        padding: EdgeInsets.zero,
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AccountMenu(),
          );
        },
        icon: const NewVersionIcon(Icons.account_circle_outlined),
      ),
    );
  }
}

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const UserMenuItem(),
            const SyncMenuItem(),
            ListTile(
              leading: const Icon(Icons.download_for_offline),
              title: Text(AppLocalizations.of(context)!.downloads),
              onTap: () {
                context.router.popAndPush(const OfflineItemsRoute());
              },
            ),
            ListTile(
              leading: const NewVersionIcon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.settings),
              onTap: () {
                context.router.popAndPush(const SettingsRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SyncMenuItem extends ConsumerWidget {
  const SyncMenuItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(userProvider).valueOrNull != null;
    final syncStatus = ref.watch(collectionSyncStatusProvider).valueOrNull ?? false;

    if (!enabled) {
      return const SizedBox.shrink();
    }

    return ListTile(
        enabled: !syncStatus,
        leading: syncStatus
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
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
        });
  }
}

class UserMenuItem extends ConsumerWidget {
  const UserMenuItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return user.maybeWhen(
      data: (user) {
        return user != null
            ? ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                leading: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircleAvatar(
                    backgroundImage: user.picture != null ? NetworkImage(user.picture!) : null,
                  ),
                ),
                title: Center(child: Text(user.name!)),
                visualDensity: VisualDensity.standard,
                trailing: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Auth().singOut();
                  },
                ),
              )
            : ListTile(
                leading: const Icon(Icons.login),
                title: Text(AppLocalizations.of(context)!.signIn),
                onTap: () {
                  Auth().signIn();
                },
              );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
