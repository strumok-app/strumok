import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/settings/color_switcher.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
  });

  testWidgets('renders color circles and moves the checkmark on selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ColorSwitcher())),
    );

    final circles = find.byWidgetPredicate(
      (widget) => widget is Material && widget.shape is CircleBorder,
    );
    expect(circles, findsNWidgets(colors.length));
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      tester
          .widget<Material>(
            find
                .ancestor(of: find.byIcon(Icons.check), matching: circles)
                .first,
          )
          .color,
      Colors.green,
    );

    final limeCircle = find.byWidgetPredicate(
      (widget) => widget is Material && widget.color == Colors.lime,
    );
    final originalSize = tester.getSize(limeCircle);
    await tester.tap(limeCircle);
    await tester.pumpAndSettle();

    expect(AppPreferences.themeColor.toARGB32(), Colors.lime.toARGB32());
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      find.descendant(of: limeCircle, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.check)).color, Colors.black);
    expect(tester.getSize(limeCircle), originalSize);
  });

  test('palette keeps eight hue families including the default green', () {
    expect(colors, hasLength(8));
    expect(colors, contains(Colors.green));
  });

  for (final brightness in Brightness.values) {
    test('generated $brightness primary hues remain distinct', () {
      final hues =
          colors
              .map(
                (color) => HSVColor.fromColor(
                  ColorScheme.fromSeed(
                    seedColor: color,
                    brightness: brightness,
                  ).primary,
                ).hue,
              )
              .toList()
            ..sort();

      for (var index = 0; index < hues.length; index++) {
        final nextHue = index + 1 < hues.length
            ? hues[index + 1]
            : hues.first + 360;
        expect(nextHue - hues[index], greaterThan(15));
      }
    });
  }
}
