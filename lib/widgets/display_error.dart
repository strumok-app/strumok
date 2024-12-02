import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';

class DisplayError extends StatelessWidget {
  final Object error;
  final VoidCallback? onRefresh;
  final List<Widget> actions;

  const DisplayError({
    super.key,
    required this.error,
    this.actions = const [],
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error.toString(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                autofocus: true,
                onPressed: () {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop();
                  } else {
                    context.router.replace(const HomeRoute());
                  }
                },
                child: Text(AppLocalizations.of(context)!.errorGoBack),
              ),
              if (onRefresh != null)
                OutlinedButton(
                  onPressed: onRefresh,
                  child: Text(AppLocalizations.of(context)!.errorReload),
                ),
              ...actions,
            ],
          )
        ],
      ),
    );
  }
}
