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

    final focusBorder = BorderSide(color: colorScheme.onSurfaceVariant);
    final navigationIndicatorShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: focusBorder,
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
        useMaterial3: true,
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.focused)
                  ? CircleBorder(side: focusBorder)
                  : null;
            }),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.focused)
                  ? RoundedRectangleBorder(
                      side: focusBorder,
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null;
            }),
          ),
        ),
        searchBarTheme: SearchBarThemeData(
          elevation: const WidgetStatePropertyAll(1),
          shape: WidgetStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: states.contains(WidgetState.focused)
                  ? focusBorder
                  : BorderSide.none,
            );
          }),
        ),
      ),
      child: child,
    );
  }
}
