import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final double contentPadding;
  final double labelWidth;
  final Widget label;
  final Widget section;

  const SettingsSection({
    super.key,
    this.contentPadding = 8,
    this.labelWidth = 300,
    required this.label,
    required this.section,
  });
  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(top: contentPadding, bottom: contentPadding);
    final labelBox = SizedBox(
      width: labelWidth,
      child: Padding(
        padding: padding,
        child: label,
      ),
    );

    final sectionBox = Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: padding,
        child: section,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [labelBox, sectionBox],
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              labelBox,
              Flexible(child: sectionBox),
            ],
          );
        }
      },
    );
  }
}
