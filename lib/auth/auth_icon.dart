import 'package:strumok/auth/auth.dart';
import 'package:strumok/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/auth/user_dialog.dart';

class DesktopAuthIcon extends ConsumerWidget {
  const DesktopAuthIcon({super.key});

  Widget _renderLogin(WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return IconButton.filledTonal(
      onPressed: () {
        auth.signIn();
      },
      icon: const Icon(Icons.login),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return user.maybeWhen(
      data: (user) {
        return user != null ? _AuthUserMenu(user: user) : _renderLogin(ref);
      },
      orElse: () => _renderLogin(ref),
    );
  }
}

class _AuthUserMenu extends ConsumerWidget {
  final User user;

  const _AuthUserMenu({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkResponse(
      radius: 24,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => UserDialog(user: user),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: user.name,
          child: CircleAvatar(
            radius: 20,
            backgroundImage:
                user.picture != null ? NetworkImage(user.picture!) : null,
          ),
        ),
      ),
    );
  }
}
