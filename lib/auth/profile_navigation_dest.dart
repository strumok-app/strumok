import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/auth/auth_provider.dart';

class ProfileNavigationDest extends ConsumerWidget {
  const ProfileNavigationDest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider);
    final user = asyncUser.value;

    return NavigationDestination(
      enabled: !asyncUser.isLoading,
      icon: user == null
          ? const Icon(Icons.login_outlined)
          : const Icon(Icons.account_circle_outlined),
      label: user == null ? "Увійти" : "Профіль",
    );
  }
}
