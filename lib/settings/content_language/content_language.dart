import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/settings/settings_provider.dart';

class ContentLanguageSelector extends ConsumerWidget {
  const ContentLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLangs = ref.watch(contentLanguageSettingsProvider);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: ContentLanguage.values
          .map((lang) => FilterChip(
                selected: selectedLangs.contains(lang),
                label: Text(lang.label),
                onSelected: (value) {
                  ref.read(contentLanguageSettingsProvider.notifier).toggleLanguage(lang);
                },
              ))
          .toList(),
    );
  }
}
