import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/search/search_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/filter_dialog_section.dart';

class FiltersButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const FilterSelectorsDialog(),
        );
      },
      icon: const Icon(Icons.tune),
    );
  }
}

class FilterSelectorsDialog extends ConsumerWidget {
  const FilterSelectorsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabledSuppliers = ref.watch(enabledSuppliersProvider).toList();
    final searchSettings = ref.watch(searchSettingsProvider);

    return Dialog(
      insetPadding: EdgeInsets.only(left: isMobile(context) ? 0 : 80.0),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterDialogSection(
                label: Text(
                  AppLocalizations.of(context)!.contentLanguage,
                  style: theme.textTheme.headlineSmall,
                ),
                itemsCount: ContentLanguage.values.length,
                itemBuilder: (context, index) {
                  final item = ContentLanguage.values[index];
                  return FilterChip(
                    selected: searchSettings.languages.contains(item),
                    label: Text(item.label),
                    onSelected: (value) {
                      ref
                          .read(searchSettingsProvider.notifier)
                          .toggleLanguage(item);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              FilterDialogSection(
                label: Text(
                  AppLocalizations.of(context)!.contentType,
                  style: theme.textTheme.headlineSmall,
                ),
                itemsCount: ContentType.values.length,
                itemBuilder: (context, index) {
                  final item = ContentType.values[index];
                  return FilterChip(
                    selected: searchSettings.types.contains(item),
                    label: Text(contentTypeLabel(context, item)),
                    onSelected: (value) {
                      ref
                          .read(searchSettingsProvider.notifier)
                          .toggleType(item);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              FilterDialogSection(
                label: Text(
                  AppLocalizations.of(context)!.suppliers,
                  style: theme.textTheme.headlineSmall,
                ),
                itemsCount: enabledSuppliers.length,
                itemBuilder: (context, index) {
                  final item = enabledSuppliers[index];
                  return FilterChip(
                    label: Text(item),
                    selected: searchSettings.searchSuppliersNames.contains(
                      item,
                    ),
                    onSelected: searchSettings.avaliableSuppliers.contains(item)
                        ? (value) {
                            ref
                                .read(searchSettingsProvider.notifier)
                                .toggleSupplierName(item);
                          }
                        : null,
                  );
                },
                onSelectAll: () {
                  ref
                      .read(searchSettingsProvider.notifier)
                      .toggleAllSuppliers(true);
                },
                onUnselectAll: () {
                  ref
                      .read(searchSettingsProvider.notifier)
                      .toggleAllSuppliers(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
