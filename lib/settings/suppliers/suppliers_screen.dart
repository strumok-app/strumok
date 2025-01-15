import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/settings/suppliers/suppliers_settings.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/back_nav_button.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SuppliersSettingsScreen extends StatelessWidget {
  const SuppliersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 3,
      child: _SuppliersSettingsView(),
    );
  }
}

class _SuppliersSettingsView extends StatelessWidget {
  const _SuppliersSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = getPadding(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!TVDetector.isTV) ...[
                    const BackNavButton(),
                    SizedBox(width: padding),
                  ],
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.settingsSuppliersAndRecommendations,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              SizedBox(height: padding),
              const SuppliersSettingsSection()
            ],
          ),
        ),
      ),
    );
  }
}
