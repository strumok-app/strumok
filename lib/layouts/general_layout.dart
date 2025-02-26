import 'package:strumok/layouts/bottom_navigation_layout.dart';
import 'package:strumok/layouts/global_notifications.dart';
import 'package:strumok/layouts/side_navigation_layout.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';

class GeneralLayout extends StatelessWidget {
  const GeneralLayout({
    super.key,
    this.showBackButton = false,
    this.selectedIndex,
    required this.child,
  });

  final bool showBackButton;
  final int? selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlobalNotifications(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileWidth) {
              return BottomNavigationLayout(
                selectedIndex: selectedIndex,
                child: child,
              );
            } else {
              return SideNavigationLayout(
                selectedIndex: selectedIndex,
                showBackButton: TVDetector.isTV ? false : showBackButton,
                child: child,
              );
            }
          },
        ),
      ),
    );
  }
}
