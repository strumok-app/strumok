import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/search/ai_search/ai_search_panel.dart';

class AISearchButton extends StatelessWidget {
  const AISearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => openAISearchPanel(context),
      icon: Icon(Symbols.chat_bubble),
    );
  }
}
