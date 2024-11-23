// ignore: implementation_imports
import 'package:auto_route/src/route/page_route_info.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/widgets/settings_icon.dart';
import 'package:flutter/material.dart';

typedef LabelBuilder = String Function(BuildContext context);
typedef RouteBuilder = PageRouteInfo Function();

class NavigationBarData {
  const NavigationBarData._({
    required this.icon,
    required this.labelBuilder,
    required this.routeBuilder,
  });

  final Widget icon;
  final LabelBuilder labelBuilder;
  final RouteBuilder routeBuilder;

  static final home = NavigationBarData._(
    icon: const Icon(Icons.home),
    labelBuilder: (context) => AppLocalizations.of(context)!.home,
    routeBuilder: () => const HomeRoute(),
  );

  static final search = NavigationBarData._(
    icon: const Icon(Icons.search),
    labelBuilder: (context) => AppLocalizations.of(context)!.search,
    routeBuilder: () => const SearchRoute(),
  );

  static final collection = NavigationBarData._(
    icon: const Icon(Icons.favorite),
    labelBuilder: (context) => AppLocalizations.of(context)!.collection,
    routeBuilder: () => const CollectionRoute(),
  );

  static final settings = NavigationBarData._(
    icon: const SettingsIcon(),
    labelBuilder: (context) => AppLocalizations.of(context)!.settings,
    routeBuilder: () => const SettingsRoute(),
  );

  static final List<NavigationBarData> routes = [
    home,
    search,
    collection,
    settings,
  ];
}
