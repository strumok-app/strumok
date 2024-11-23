import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:strumok/app_router.gr.dart';

class BackNavButton extends StatelessWidget {
  final Color? color;

  const BackNavButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: color,
      onPressed: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          context.router.replace(const HomeRoute());
        }
      },
    );
  }
}
