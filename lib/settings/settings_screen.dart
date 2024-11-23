import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/settings/app_version/app_version_settings.dart';
import 'package:strumok/settings/suppliers/suppliers_bundle_version_settings.dart';
import 'package:strumok/settings/theme/brightness_switcher.dart';
import 'package:strumok/settings/theme/color_switcher.dart';
import 'package:flutter/material.dart';
import 'package:strumok/widgets/settings_section.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 3,
      child: _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                AppLocalizations.of(context)!.settings,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsTheme,
                    const BrightnessSwitcher(),
                  ),
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsColor,
                    const ColorSwitcher(),
                  ),
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsVersion,
                    const AppVersionSettings(),
                  ),
                  _renderSection(
                    context,
                    AppLocalizations.of(context)!.settingsSuppliersVersion,
                    const SuppliersBundleVersionSettings(),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.chevron_right),
                    horizontalTitleGap: 8,
                    title: Text(
                      AppLocalizations.of(context)!
                          .settingsSuppliersAndRecommendations,
                    ),
                    onTap: () {
                      context.router.push(const SuppliersSettingsRoute());
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderSection(BuildContext context, String label, Widget section) {
    return SettingsSection(
      labelWidth: 200,
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      section: section,
    );
  }
}
