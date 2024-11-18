import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/auth/auth_provider.dart';
import 'package:strumok/auth/profile_navigation_dest.dart';
import 'package:strumok/auth/user_dialog.dart';
import 'package:strumok/layouts/navigation_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationLayout extends ConsumerWidget {
  const BottomNavigationLayout({
    super.key,
    this.selectedIndex,
    this.floatingActionButton,
    required this.child,
  });

  final int? selectedIndex;
  final Widget? floatingActionButton;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = NavigationRoute.routes
        .map(
          (r) => NavigationDestination(
            icon: r.icon,
            label: r.labelBuilder(context),
          ),
        )
        .toList();

    final routesActions =
        NavigationRoute.routes.map((r) => () => context.go(r.path)).toList();

    final destinations = [
      ...routes,
      const ProfileNavigationDest(),
    ];

    final actions = [
      ...routesActions,
      () {
        final user = ref.read(userProvider).valueOrNull;
        if (user == null) {
          Auth.instance.signIn();
        } else {
          showDialog(context: context, builder: (_) => UserDialog(user: user));
        }
      },
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 56,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: selectedIndex ?? 0,
        destinations: destinations,
        onDestinationSelected: (index) => actions[index](),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
