import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/search/ai_search/ai_search_panel.dart';
import 'package:strumok/search/ai_search/ai_search_provider.dart';

class AISearchButton extends ConsumerWidget {
  const AISearchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSearchAvaliable = ref.watch(isAISearchAvaliableProvider);
    final l10n = AppLocalizations.of(context)!;

    if (!aiSearchAvaliable) {
      return Tooltip(
        message: l10n.aiSearchUnavailableTooltip,
        child: IconButton(onPressed: null, icon: Icon(Icons.chat_bubble_outline)),
      );
    }

    return IconButton(
      onPressed: () => openAISearchPanel(context),
      icon: Icon(Icons.chat_bubble_outline),
    );
  }
}
