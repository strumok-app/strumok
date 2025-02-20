import 'package:flutter/material.dart';

class NothingToShow extends StatelessWidget {
  const NothingToShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "¯\\(°_o)/¯",
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
