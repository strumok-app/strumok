import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/settings/suppliers/suppliers_settings.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SuppliersSettingsScreen extends StatelessWidget {
  const SuppliersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      child: _SuppliersSettingsView(),
    );
  }
}

class _SuppliersSettingsView extends StatelessWidget {
  const _SuppliersSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  if (!TVDetector.isTV) ...[
                    const BackNavButton(),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.settingsSuppliersAndRecommendations,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: SingleChildScrollView(child: SuppliersSettingsSection()))
          ],
        ),
      ),
    );
  }
}
