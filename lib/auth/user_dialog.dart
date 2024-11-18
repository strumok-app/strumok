import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/collection/collection_sync.dart';
import 'package:strumok/layouts/app_theme.dart';

class UserDialog extends StatelessWidget {
  final User user;

  const UserDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      child: Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      user.picture != null ? NetworkImage(user.picture!) : null,
                ),
                title: Text(user.name!),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(AppLocalizations.of(context)!.reload),
                onTap: () => CollectionSync.run(),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.singOut),
                onTap: () {
                  context.pop();
                  Auth.instance.singOut();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
