import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/utils/visual.dart';

void openAISearchPanel(BuildContext context) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) =>
        Align(alignment: Alignment.centerRight, child: _AISearchPanel()),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: Duration(milliseconds: 500),
    barrierLabel: "ai_search_panel",
    barrierDismissible: true,
    barrierColor: Colors.transparent,
  );
}

class _AISearchPanel extends StatelessWidget {
  const _AISearchPanel();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final mobile = isMobile(context);

    const radius = Radius.circular(16);

    return Container(
      padding: mobile ? EdgeInsets.zero : const EdgeInsets.all(8.0),
      width: mobile ? double.infinity : 460,
      height: size.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.only(
          topLeft: mobile ? Radius.zero : radius,
          bottomLeft: mobile ? Radius.zero : radius,
        ),
      ),
      child: Material(
        child: Column(
          children: [
            _renderTitle(theme, context),
            Expanded(child: Placeholder()),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Ask about movies, series, actors",
                border: OutlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.send_rounded),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _renderTitle(ThemeData theme, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("AI Search", style: theme.textTheme.headlineMedium),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Symbols.delete_history),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
