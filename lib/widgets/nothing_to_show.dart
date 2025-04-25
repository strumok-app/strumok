import 'package:flutter/material.dart';

const asciiText = "¯\\(°_o)/¯";

class NothingToShow extends StatelessWidget {
  Widget? label;

  NothingToShow({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final icon = Text(asciiText, style: Theme.of(context).textTheme.bodyLarge);

    if (label == null) {
      return icon;
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [icon, label!]);
  }
}
