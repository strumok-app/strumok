import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaReaderSettingsDialog extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReaderSettingsDialog({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTheme(
      child: Dialog(
        insetPadding: EdgeInsets.all(8),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(8),
          child: FocusScope(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _MangaReaderBackgroundSelector(),
                const SizedBox(height: 8),
                MangaTranslationSelector(
                  contentDetails: contentDetails,
                  mediaItems: mediaItems,
                ),
                const SizedBox(height: 8),
                const _MangaReaderModeSelector(),
                const SizedBox(height: 8),
                const _MangaReaderAutoCropSelector(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MangaReaderBackgroundSelector extends ConsumerWidget {
  const _MangaReaderBackgroundSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentBackground = ref.watch(mangaReaderBackgroundSettingsProvider);

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(
            AppLocalizations.of(context)!.mangaReaderBackground,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        Spacer(),
        Dropdown.button(
          label: mangaReaderBackgroundLabel(context, currentBackground),
          menuChildrenBulder: (focusNode) => MangaReaderBackground.values
              .mapIndexed(
                (index, value) => MenuItemButton(
                  focusNode: index == 0 ? focusNode : null,
                  onPressed: () {
                    ref
                        .read(mangaReaderBackgroundSettingsProvider.notifier)
                        .select(value);
                  },
                  child: Text(mangaReaderBackgroundLabel(context, value)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class MangaTranslationSelector extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaTranslationSelector({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(collectionItemProvider(contentDetails)).value;

    if (currentItem == null) {
      return SizedBox.shrink();
    }

    final mediaItem = mediaItems[currentItem.currentItem];

    return FutureBuilder(
      future: Future.value(mediaItem.sources),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return SizedBox.shrink();
        }

        final sources = snapshot.data!;
        final currentSource = currentItem.currentSourceName;

        return _renderSources(context, ref, sources, currentSource);
      },
    );
  }

  Widget _renderSources(
    BuildContext context,
    WidgetRef ref,
    List<ContentMediaItemSource> sources,
    String? currentSource,
  ) {
    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(
            AppLocalizations.of(context)!.mangaTranslation,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        Spacer(),
        Dropdown.button(
          label: currentSource ?? sources.first.description,
          menuChildrenBulder: (focusNode) => sources
              .mapIndexed(
                (index, value) => MenuItemButton(
                  focusNode: index == 0 ? focusNode : null,
                  onPressed: () {
                    ref
                        .read(collectionItemProvider(contentDetails).notifier)
                        .setCurrentSource(value.description);
                  },
                  child: Text(value.description),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MangaReaderModeSelector extends ConsumerWidget {
  const _MangaReaderModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(mangaReaderModeSettingsProvider);

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(
            AppLocalizations.of(context)!.mangaReaderMode,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        Spacer(),
        Dropdown.button(
          label: mangaReaderModeLabel(context, currentMode),
          menuChildrenBulder: (focusNode) => MangaReaderMode.values
              .mapIndexed(
                (index, value) => MenuItemButton(
                  focusNode: index == 0 ? focusNode : null,
                  onPressed: () {
                    ref
                        .read(mangaReaderModeSettingsProvider.notifier)
                        .select(value);
                  },
                  child: Text(mangaReaderModeLabel(context, value)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MangaReaderAutoCropSelector extends ConsumerWidget {
  const _MangaReaderAutoCropSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final autoCropEnabled = ref.watch(mangaReaderAutoCropSettingsProvider);

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(
            AppLocalizations.of(context)!.mangaReaderAutoCrop,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        Spacer(),
        Switch(
          value: autoCropEnabled,
          onChanged: (value) {
            ref
                .read(mangaReaderAutoCropSettingsProvider.notifier)
                .toggle(value);
          },
        ),
      ],
    );
  }
}
