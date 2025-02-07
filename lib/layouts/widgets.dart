import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.isSelected,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      )),
    );

    final button = isSelected
        ? IconButton.outlined(
            padding: EdgeInsets.zero,
            style: style,
            onPressed: onPressed,
            icon: icon,
          )
        : IconButton(
            padding: EdgeInsets.zero,
            style: style,
            onPressed: onPressed,
            icon: icon,
          );

    return SizedBox(
      height: 32,
      width: 56,
      child: button,
    );
  }
}
