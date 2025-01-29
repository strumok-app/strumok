import 'package:auto_route/auto_route.dart';
import 'package:strumok/layouts/navigation_bar_data.dart';
import 'package:strumok/layouts/account.dart';
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
    final routes = NavigationBarData.routes
        .map(
          (r) => NavigationRailDestination(
            icon: r.icon,
            label: Text(r.labelBuilder(context)),
          ),
        )
        .toList();

    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: NavigationRail(
              leading: showBackButton ? const BackNavButton() : const SizedBox.square(dimension: 40),
              trailing: const AccountMenuIcon(),
              selectedIndex: selectedIndex,
              // groupAlignment: 0.0,
              destinations: routes,
              onDestinationSelected: (index) {
                final routeBuilder = NavigationBarData.routes[index].routeBuilder;
                context.router.replace(routeBuilder());
              },
            ),
          ),
          Expanded(child: child)
        ],
      ),
    );
  }
}
