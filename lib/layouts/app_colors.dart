import 'package:flutter/material.dart';

enum AppColorScheme {
  crimson(Color(0xFFE62117)),
  monochrome(Color(0xFF757575)),
  khaki(Color(0xFFC3B091)),
  olive(Color(0xFF708238)),
  amber(Color(0xFFFFB300)),
  electricViolet(Color(0xFF7C4DFF)),
  cobalt(Color(0xFF1E88E5)),
  neonCyan(Color(0xFF00E5FF));

  // sage(Color(0xFF5F8D75)),
  // copper(Color(0xFFB87333)),
  // slate(Color(0xFF546E7A)),
  // sunsetCoral(Color(0xFFFF6D00)),
  // neonEmerald(Color(0xFF00E676))
  // coffee(Color(0xFF8D6E63)),
  // plum(Color(0xFF8E24AA)),
  // electricViolet(Color(0xFF7C4DFF)),

  const AppColorScheme(this.color);

  static const AppColorScheme defaultScheme = olive;

  final Color color;

  ColorScheme colorScheme(Brightness brightness) =>
      _cache[(this, brightness)] ??= _build(this, brightness);

  static AppColorScheme fromName(String? name) =>
      values.where((scheme) => scheme.name == name).firstOrNull ??
      defaultScheme;
}

final _cache = <(AppColorScheme, Brightness), ColorScheme>{};

ColorScheme _build(AppColorScheme scheme, Brightness brightness) =>
    switch (scheme) {
      AppColorScheme.crimson => _crimson(brightness),
      AppColorScheme.monochrome => _monochrome(brightness),
      _ => _fromSeed(scheme.color, brightness),
    };

ColorScheme _fromSeed(Color seed, Brightness brightness) =>
    ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

ColorScheme _monochrome(Brightness brightness) => ColorScheme.fromSeed(
  seedColor: Colors.grey,
  brightness: brightness,
  dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
);

// Neutral (untinted) surfaces with only the primary roles taken from accent,
// so the red accent stays reserved for primary actions and progress (YouTube style).
ColorScheme _crimson(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final accentScheme = _fromSeed(const Color(0xFFFF0000), brightness);
  return _monochrome(brightness).copyWith(
    primary: isDark ? const Color(0xFFE62117) : const Color(0xFFCC0000),
    onPrimary: Colors.white,
    primaryContainer: accentScheme.primaryContainer,
    onPrimaryContainer: accentScheme.onPrimaryContainer,
    primaryFixed: accentScheme.primaryFixed,
    primaryFixedDim: accentScheme.primaryFixedDim,
    onPrimaryFixed: accentScheme.onPrimaryFixed,
    onPrimaryFixedVariant: accentScheme.onPrimaryFixedVariant,
    inversePrimary: accentScheme.inversePrimary,
    surface: isDark ? const Color(0xFF0F0F0F) : Colors.white,
  );
}
