import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/widgets/settings_section.dart';
import 'package:url_launcher/url_launcher.dart';

class AISearchSettings extends ConsumerStatefulWidget {
  const AISearchSettings({super.key});

  @override
  ConsumerState<AISearchSettings> createState() => _AISearchSettingsState();
}

class _AISearchSettingsState extends ConsumerState<AISearchSettings> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = ref.read(geminiApiTokenProvider) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final currentToken = ref.watch(geminiApiTokenProvider) ?? "";
    final aiSearchEnabled = ref.watch(aiSearchEnabledProvider);
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.aiSearchTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Switch(
              value: aiSearchEnabled,
              onChanged: (value) {
                ref.read(aiSearchEnabledProvider.notifier).toggle(value);
              },
            ),
          ],
        ),
        if (aiSearchEnabled)
          SettingsSection(
            labelWidth: 300,
            label: Row(
              children: [
                Text(l10n.settingsAiSearchGeminiApiToken),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse("https://aistudio.google.com/app/apikey"),
                    );
                  },
                  child: Text(l10n.settingsAiSearchGet),
                ),
              ],
            ),
            section: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: l10n.settingsAiSearchTokenHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),

                      onSubmitted: (value) {
                        value = value.trim();
                        ref
                            .read(geminiApiTokenProvider.notifier)
                            .set(value.isEmpty ? null : value);
                      },
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _textController,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _getEditButtons(value.text, currentToken),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _getEditButtons(String editingToken, String currentToken) {
    if (editingToken != currentToken)
      return [
        IconButton(
          onPressed: () {
            _textController.value = TextEditingValue(text: currentToken);
          },
          icon: Icon(Icons.close),
        ),
        IconButton(
          onPressed: () {
            final value = _textController.text.trim();
            ref
                .read(geminiApiTokenProvider.notifier)
                .set(value.isEmpty ? null : value);
          },
          icon: Icon(Icons.check),
        ),
      ];

    if (editingToken.isNotEmpty)
      return [
        IconButton(
          onPressed: () {
            _textController.clear();
            ref.read(geminiApiTokenProvider.notifier).set(null);
          },
          icon: Icon(Icons.delete),
        ),
      ];

    return [];
  }
}
