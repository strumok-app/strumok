import 'package:strumok/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const colors = [
  Colors.red,
  Colors.orange,
  Colors.lime,
  Colors.green,
  Colors.teal,
  Colors.blue,
  Colors.deepPurple,
  Colors.pink,
];

class ColorSwitcher extends ConsumerWidget {
  const ColorSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(colorSettingsProvider);
    final availableColors = [
      ...colors,
      if (!colors.any((color) => color.toARGB32() == selected.toARGB32()))
        selected,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: AlignmentGeometry.topRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 4,
          runSpacing: 4,
          children: availableColors
              .map((color) => _ColorSelector(color: color, selected: selected))
              .toList(),
        ),
      ),
    );
  }
}

class _ColorSelector extends ConsumerStatefulWidget {
  const _ColorSelector({required this.color, required this.selected});

  final Color color;
  final Color selected;

  @override
  ConsumerState<_ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends ConsumerState<_ColorSelector> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = widget.color.toARGB32() == widget.selected.toARGB32();
    final checkColor =
        ThemeData.estimateBrightnessForColor(widget.color) == Brightness.light
        ? Colors.black
        : Colors.white;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: widget.color,
        shape: CircleBorder(
          side: BorderSide(
            color: colorScheme.onSurfaceVariant,
            width: focused ? 3 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkResponse(
          onTap: () {
            ref.read(colorSettingsProvider.notifier).select(widget.color);
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
              child: isSelected
                  ? Icon(Icons.check, color: checkColor, size: 20)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
