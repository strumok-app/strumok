import 'package:strumok/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme extends ConsumerWidget {
  final Widget child;

  const AppTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessSettingProvider);
    final color = ref.watch(colorSettingsProvider);

    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness ?? MediaQuery.platformBrightnessOf(context),
      seedColor: color,
    );

    final navigationIndicatorShape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      side: BorderSide(width: 2, color: colorScheme.onSurfaceVariant),
    );

    return Theme(
      data: ThemeData(
        colorScheme: colorScheme,
        navigationRailTheme: NavigationRailThemeData(
          indicatorShape: navigationIndicatorShape,
          indicatorColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorShape: navigationIndicatorShape,
          indicatorColor: Colors.transparent,
        ),
        focusColor: Colors.white.withAlpha(60),
        useMaterial3: true,
      ),
      child: child,
    );
  }
}
