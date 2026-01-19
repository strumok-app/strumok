import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/settings/app_version/app_version_settings.dart';
import 'package:strumok/settings/content_language.dart';
import 'package:strumok/settings/suppliers/suppliers_bundle_version_settings.dart';
import 'package:strumok/settings/brightness_switcher.dart';
import 'package:strumok/settings/color_switcher.dart';
import 'package:flutter/material.dart';
import 'package:strumok/settings/user_language.dart';
import 'package:strumok/settings/offline_storage_directory.dart';
import 'package:strumok/widgets/settings_section.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(child: _SettingsView());
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.settings,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
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
              _renderSection(
                context,
                AppLocalizations.of(context)!.language,
                const UserLanguage(),
              ),
              _renderSection(
                context,
                AppLocalizations.of(context)!.contentLanguage,
                const ContentLanguageSelector(),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.chevron_right),
                horizontalTitleGap: 8,
                title: Text(
                  AppLocalizations.of(
                    context,
                  )!.settingsSuppliersAndRecommendations,
                ),
                onTap: () {
                  context.navigateTo(const SuppliersSettingsRoute());
                },
              ),
              _renderSection(
                context,
                AppLocalizations.of(context)!.settingsTheme,
                const BrightnessSwitcher(),
              ),
              const ColorSwitcher(),
              _renderSection(
                context,
                AppLocalizations.of(context)!.settingsDownloadsDirectory,
                const OfflineStorageDirectorySelector(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderSection(BuildContext context, String label, Widget section) {
    return SettingsSection(
      labelWidth: 200,
      label: Text(label, style: Theme.of(context).textTheme.titleMedium),
      section: section,
    );
  }
}
