import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/search/ai_search/ai_search_panel.dart';
import 'package:strumok/search/ai_search/ai_search_provider.dart';

class AISearchButton extends ConsumerWidget {
  const AISearchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSearchAvaliable = ref.watch(isAISearchAvaliableProvider);

    if (!aiSearchAvaliable) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () => openAISearchPanel(context),
      icon: Icon(Symbols.chat_bubble),
    );
  }
}
