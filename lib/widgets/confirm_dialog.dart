import 'package:flutter/material.dart';
import 'package:strumok/app_localizations.dart';

class ConfirmDialog extends StatelessWidget {
  final Widget content;
  final String? confirmLabel;
  final VoidCallback confimAction;

  const ConfirmDialog({
    super.key,
    required this.content,
    this.confirmLabel,
    required this.confimAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: content,
      actionsPadding: EdgeInsets.only(right: 8, bottom: 8),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.confirmeDialogCancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            confimAction();
          },
          child: Text(confirmLabel ?? AppLocalizations.of(context)!.confirmeDialogAccept),
        )
      ],
    );
  }
}
