import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.dart';
import 'package:strumok/settings/app_version/next_gen_app_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Transparent startup wrapper that, once per app launch, suggests the user to
/// install the next generation app published in a separate repository.
class NextGenAppPrompt extends ConsumerStatefulWidget {
  const NextGenAppPrompt(this.appRouter, {super.key, required this.child});

  final AppRouter appRouter;
  final Widget child;

  @override
  ConsumerState<NextGenAppPrompt> createState() => _NextGenAppPromptState();
}

class _NextGenAppPromptState extends ConsumerState<NextGenAppPrompt> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    if (!_handled) {
      final info = ref.watch(nextGenAppInfoProvider).asData?.value;

      if (info != null) {
        _handled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showPrompt(info);
          }
        });
      }
    }

    return widget.child;
  }

  void _showPrompt(NextGenAppInfo info) {
    // The prompt lives above the router's Navigator (MaterialApp.builder), so
    // the dialog must be shown with a context that is below that Navigator.
    final navigatorContext = widget.appRouter.navigatorKey.currentContext;

    if (navigatorContext == null) {
      return;
    }

    showDialog(
      context: navigatorContext,
      builder: (context) => _NextGenAppDialog(info: info),
    );
  }
}

class _NextGenAppDialog extends ConsumerWidget {
  const _NextGenAppDialog({required this.info});

  final NextGenAppInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final state = ref.watch(nextGenAppInstallProvider);
    final failed = state.error != null;

    ref.listen(nextGenAppInstallProvider, (prev, next) {
      if (prev?.completed != true && next.completed && next.error == null) {
        Navigator.of(context).pop();
      }
    });

    return AlertDialog(
      title: Text(localizations.nextGenPromptTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.nextGenPromptMessage(info.title)),
          if (state.downloading) ...[
            const SizedBox(height: 16),
            Text(localizations.nextGenPromptDownloading),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.progress == 0 ? null : state.progress,
            ),
          ],
          if (failed) ...[
            const SizedBox(height: 16),
            Text(
              localizations.nextGenPromptInstallFailed,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.nextGenPromptLater),
        ),
        if (failed)
          FilledButton(
            autofocus: true,
            onPressed: () {
              launchUrlString(info.htmlUrl);
              Navigator.of(context).pop();
            },
            child: Text(localizations.nextGenPromptOpenReleasePage),
          )
        else
          FilledButton(
            autofocus: true,
            onPressed: state.downloading
                ? null
                : () => ref
                      .read(nextGenAppInstallProvider.notifier)
                      .install(info),
            child: Text(localizations.nextGenPromptInstall),
          ),
      ],
    );
  }
}
