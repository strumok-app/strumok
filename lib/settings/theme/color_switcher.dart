import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colors = [
  Colors.deepOrange,
  Colors.orange,
  Colors.amber,
  Colors.yellow,
  Colors.lime,
  Colors.lightGreen,
  Colors.green,
  Colors.teal,
  Colors.cyan,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.deepPurple,
];

class ColorSwitcher extends ConsumerWidget {
  const ColorSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(colorSettingsProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors
          .map(
            (color) =>
                _ColorSelector(color: color, selected: selected, ref: ref),
          )
          .toList(),
    );
  }
}

class _ColorSelector extends HookWidget {
  const _ColorSelector({
    required this.color,
    required this.selected,
    required this.ref,
  });

  final Color color;
  final Color selected;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final focused = useState(false);
    final colorSchema = Theme.of(context).colorScheme;

    final icon = color.value == selected.value
        ? const Icon(
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black,
              )
            ],
            Icons.check,
          )
        : null;

    return InkResponse(
      onTap: () {
        ref.read(colorSettingsProvider.notifier).select(color);
      },
      radius: 20,
      onFocusChange: (value) => focused.value = value,
      focusColor: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          height: 32,
          width: 32,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorSchema.onSurfaceVariant),
                shape: BoxShape.circle,
              ),
              height: focused.value ? 32 : 26,
              width: focused.value ? 32 : 26,
              child: CircleAvatar(
                backgroundColor: color,
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
