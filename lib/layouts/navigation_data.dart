import 'package:strumok/app_localizations.dart';
import 'package:strumok/widgets/settings_icon.dart';
import 'package:flutter/material.dart';

typedef LabelBuilder = String Function(BuildContext context);

class NavigationRoute {
  const NavigationRoute._(
      {required this.path, required this.icon, required this.labelBuilder});

  final String path;
  final Widget icon;
  final LabelBuilder labelBuilder;

  static final home = NavigationRoute._(
    path: "/",
    icon: const Icon(Icons.home),
    labelBuilder: (context) => AppLocalizations.of(context)!.home,
  );
  static final search = NavigationRoute._(
    path: "/search",
    icon: const Icon(Icons.search),
    labelBuilder: (context) => AppLocalizations.of(context)!.search,
  );
  static final collection = NavigationRoute._(
    path: "/collection",
    icon: const Icon(Icons.favorite),
    labelBuilder: (context) => AppLocalizations.of(context)!.collection,
  );
  static final settings = NavigationRoute._(
    path: "/settings",
    icon: const SettingsIcon(),
    labelBuilder: (context) => AppLocalizations.of(context)!.settings,
  );

  static final List<NavigationRoute> routes = [
    home,
    search,
    collection,
    settings
  ];
}
