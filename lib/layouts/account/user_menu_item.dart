import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/auth/auth_provider.dart';
import 'package:strumok/layouts/account/connect_tv_code.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/tv.dart';

class UserMenuItem extends ConsumerWidget {
  const UserMenuItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineMode = ref.watch(offlineModeProvider);
    final user = ref.watch(userProvider);

    if (offlineMode) {
      return SizedBox.shrink();
    }

    return user.maybeWhen(
      data: (user) {
        return user != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _renderUserInfo(user),
                  if (!TVDetector.isTV) ConnectTVCode(),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _renderSignIn(context),
                  if (TVDetector.isTV) ConnectTVWithCode(),
                ],
              );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _renderSignIn(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.login),
      title: Text(AppLocalizations.of(context)!.signIn),
      onTap: () {
        Auth().signIn();
      },
    );
  }

  Widget _renderUserInfo(User user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: SizedBox(
        height: 48,
        width: 48,
        child: CircleAvatar(
          backgroundImage: user.picture != null
              ? NetworkImage(user.picture!)
              : null,
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
    );
  }
}
