import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/search/ai_search/ai_search_provider.dart';
import 'package:strumok/search/search_provider.dart';
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

class _AISearchPanel extends ConsumerWidget {
  const _AISearchPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _renderTitle(theme, context, ref),
            Expanded(child: _AISearchHistory()),
            SizedBox(height: 8),
            _AIPanelInput(),
          ],
        ),
      ),
    );
  }

  Row _renderTitle(ThemeData theme, BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              AppLocalizations.of(context)!.aiSearchTitle,
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Tooltip(
            message: AppLocalizations.of(context)!.aiSearchClearChat,
            child: IconButton(
              onPressed: () {
                ref.read(aIChatProvider.notifier).reset();
              },
              icon: Icon(Symbols.delete_history),
            ),
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

class _AIPanelInput extends ConsumerStatefulWidget {
  const _AIPanelInput();

  @override
  ConsumerState<_AIPanelInput> createState() => _AIPanelInputState();
}

class _AIPanelInputState extends ConsumerState<_AIPanelInput> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(
      aIChatProvider.select((state) => state.isLoading),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: null,
              controller: _textController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.aiSearchHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
              ),
              onSubmitted: (value) {
                if (isLoading) return;
                ref
                    .read(aIChatProvider.notifier)
                    .sendMessage(_textController.text);
                _textController.clear();
              },
            ),
          ),

          const SizedBox(width: 12.0),

          isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  onPressed: () {
                    ref
                        .read(aIChatProvider.notifier)
                        .sendMessage(_textController.text);
                    _textController.clear();
                  },
                  icon: const Icon(Icons.send_rounded),
                ),
        ],
      ),
    );
  }
}

class _AISearchHistory extends ConsumerStatefulWidget {
  const _AISearchHistory();

  @override
  ConsumerState<_AISearchHistory> createState() => _AISearchHistoryState();
}

class _AISearchHistoryState extends ConsumerState<_AISearchHistory> {
  final ScrollController _scrollController = ScrollController();
  late final ProviderSubscription _sub;

  @override
  void initState() {
    _sub = ref.listenManual(aIChatProvider.select((chat) => chat.messages), (
      previous,
      next,
    ) {
      if (next.length > (previous?.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    super.initState();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(aIChatProvider);

    if (chatState.messages.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.aiSearchEmpty,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];

        if (message is UserMessage) {
          return _UserMessageBubble(message: message);
        }

        if (message is ModelMessage) {
          return _ModelMessageBubble(message: message);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.message});

  final UserMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _ModelMessageBubble extends ConsumerWidget {
  const _ModelMessageBubble({required this.message});

  final ModelMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (message.error != null && message.error!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.error!,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.description.isNotEmpty)
                Text(
                  message.description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              if (message.recommendations.isNotEmpty) ...[
                if (message.description.isNotEmpty) const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: message.recommendations.map((recommendation) {
                    return OutlinedButton(
                      onPressed: () {
                        ref
                            .read(searchProvider.notifier)
                            .search(recommendation.title);

                        Navigator.of(context).pop();
                      },
                      child: Text(recommendation.title),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
