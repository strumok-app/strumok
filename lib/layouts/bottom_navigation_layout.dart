import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/layouts/account.dart';
import 'package:strumok/layouts/navigation_bar_data.dart';
import 'package:flutter/material.dart';

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
              (idx, r) => buildButton(
                () => context.router.replace(r.routeBuilder()),
                r.icon,
                idx == selectedIndex,
              ),
            ),
            const AccountMenuIcon(),
          ],
        ),
      ),
    );
  }

  Widget buildButton(VoidCallback onPressed, Widget icon, bool isSelected) {
    final style = ButtonStyle(
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      )),
    );

    final button = isSelected
        ? IconButton.outlined(
            padding: EdgeInsets.zero,
            style: style,
            onPressed: onPressed,
            icon: icon,
          )
        : IconButton(
            padding: EdgeInsets.zero,
            style: style,
            onPressed: onPressed,
            icon: icon,
          );

    return SizedBox(
      height: 32,
      width: 56,
      child: button,
    );
  }
}
