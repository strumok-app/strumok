import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/widgets/dropdown.dart';

class UserLanguage extends ConsumerWidget {
  static final langs = {"uk": "Українська", "en": "English"};

  const UserLanguage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLang = ref.watch(userLanguageSettingProvider);
    return Dropdown.button(
      label: langs[userLang] ?? "",
      menuChildrenBulder:
          (focusNode) =>
              langs.keys
                  .mapIndexed(
                    (index, lang) => MenuItemButton(
                      focusNode: index == 0 ? focusNode : null,
                      child: Text(langs[lang]!),
                      onPressed: () {
                        ref
                            .read(userLanguageSettingProvider.notifier)
                            .select(lang);
                      },
                    ),
                  )
                  .toList(),
    );
  }
}
