import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:strumok/download/downloading_queue.dart';
import 'package:strumok/layouts/navigation_bar_data.dart';
import 'package:strumok/layouts/account.dart';
import 'package:strumok/layouts/widgets.dart';
import 'package:strumok/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';

class SideNavigationLayout extends StatelessWidget {
  const SideNavigationLayout({
    super.key,
    this.selectedIndex,
    this.showBackButton = false,
    required this.child,
  });

  final bool showBackButton;
  final int? selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox.square(
                  dimension: 40,
                  child: showBackButton ? const BackNavButton() : null,
                ),
                ...NavigationBarData.routes.mapIndexed(
                  (idx, r) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: NavigationButton(
                      onPressed: () => context.navigateTo(r.routeBuilder()),
                      icon: r.icon,
                      isSelected: idx == selectedIndex,
                    ),
                  ),
                ),
                const AccountMenuIcon(),
                const Spacer(),
                const DownloadingQueue(),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
