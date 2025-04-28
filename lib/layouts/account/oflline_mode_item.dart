import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/settings/settings_provider.dart';

class OfllineModeItem extends ConsumerWidget {
  const OfllineModeItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(offlineModeProvider);

    return ListTile(
      contentPadding: EdgeInsets.only(left: 16, right: 8),
      leading: const Icon(Icons.wifi_off),
      title: Text(AppLocalizations.of(context)!.offlineMode),
      trailing: Switch(
        value: mode,
        onChanged: (value) {
          ref.read(offlineModeProvider.notifier).select(value);
        },
      ),
    );
  }
}
