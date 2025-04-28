import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/layouts/account/account.dart';
import 'package:strumok/layouts/navigation_bar_data.dart';
import 'package:flutter/material.dart';
import 'package:strumok/layouts/widgets.dart';

class BottomNavigationLayout extends ConsumerWidget {
  const BottomNavigationLayout({
    super.key,
    this.selectedIndex,
    required this.child,
  });

  final int? selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomAppBar(
        height: 48,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ...NavigationBarData.routes.mapIndexed(
              (idx, r) => NavigationButton(
                onPressed: () => context.navigateTo(r.routeBuilder()),
                icon: r.icon,
                isSelected: idx == selectedIndex,
              ),
            ),
            const AccountMenuIcon(),
          ],
        ),
      ),
    );
  }
}
