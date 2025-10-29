import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FocusIndicator extends StatefulWidget {
  final Widget child;

  const FocusIndicator({super.key, required this.child});

  @override
  State<FocusIndicator> createState() => _FocusIndicatorState();
}

class _FocusIndicatorState extends State<FocusIndicator> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Focus(
      onFocusChange: (value) {
        setState(() {
          focused = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: focused
                  ? colorScheme.onSurfaceVariant
                  : Colors.transparent,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
