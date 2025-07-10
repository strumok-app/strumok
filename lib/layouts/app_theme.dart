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
        splashFactory: NoSplash.splashFactory,
        colorScheme: colorScheme,
        navigationRailTheme: NavigationRailThemeData(
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
            padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
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
            padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
          ),
        ),
        searchBarTheme: SearchBarThemeData(
          elevation: const WidgetStatePropertyAll(1),
          shape: WidgetStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side:
                  states.contains(WidgetState.focused)
                      ? focusBorder
                      : BorderSide.none,
            );
          }),
        ),
        searchViewTheme: SearchViewThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.onSurfaceVariant),
          ),
        ),
        sliderTheme: SliderThemeData(activeTrackColor: colorScheme.primary),
      ),
      child: child,
    );
  }
}
