import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class FocusIndicator extends HookWidget {
  final Widget child;

  const FocusIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final focused = useState(false);
    final colorScheme = Theme.of(context).colorScheme;

    return Focus(
      onFocusChange: (value) => focused.value = value,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: focused.value
                  ? colorScheme.onSurfaceVariant
                  : Colors.transparent,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
