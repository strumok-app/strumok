import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/download/downloading_icon.dart';
import 'package:strumok/layouts/account/oflline_mode_item.dart';
import 'package:strumok/layouts/account/user_menu_item.dart';
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            const OfllineModeItem(),
            ListTile(
              leading: const DownloadingIcon(Icons.download_for_offline),
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
