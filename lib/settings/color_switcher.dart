import 'package:strumok/layouts/app_colors.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColorSwitcher extends ConsumerWidget {
  const ColorSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(colorSchemeSettingProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: AlignmentGeometry.topRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 4,
          runSpacing: 4,
          children: AppColorScheme.values
              .map(
                (scheme) => _ColorSchemeSelector(
                  scheme: scheme,
                  selected: scheme == selected,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ColorSchemeSelector extends ConsumerStatefulWidget {
  const _ColorSchemeSelector({required this.scheme, required this.selected});

  final AppColorScheme scheme;
  final bool selected;

  @override
  ConsumerState<_ColorSchemeSelector> createState() =>
      _ColorSchemeSelectorState();
}

class _ColorSchemeSelectorState extends ConsumerState<_ColorSchemeSelector> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.scheme.color;
    final checkColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
        ? Colors.black
        : Colors.white;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.scheme.name,
      child: Material(
        color: color,
        shape: CircleBorder(
          side: BorderSide(
            color: colorScheme.onSurfaceVariant,
            width: focused ? 3 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkResponse(
          onTap: () {
            ref.read(colorSchemeSettingProvider.notifier).select(widget.scheme);
          },
          onFocusChange: (value) {
            setState(() {
              focused = value;
            });
          },
          mouseCursor: SystemMouseCursors.click,
          customBorder: const CircleBorder(),
          containedInkWell: true,
          focusColor: Colors.transparent,
          child: SizedBox.square(
            dimension: 32,
            child: Center(
              child: widget.selected
                  ? Icon(Icons.check, color: checkColor, size: 20)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
