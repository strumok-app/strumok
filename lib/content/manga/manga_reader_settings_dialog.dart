import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/manga_provider.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/widgets/settings_section.dart';

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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
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

    return SettingsSection(
      labelWidth: 400,
      label: Text(
        AppLocalizations.of(context)!.mangaReaderBackground,
        style: theme.textTheme.headlineSmall,
      ),
      section: Dropdown.button(
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
    final currentSource = ref
        .watch(collectionItemCurrentSourceNameProvider(contentDetails))
        .valueOrNull;

    return ref
            .watch(mangaMediaItemSourcesProvider(contentDetails, mediaItems))
            .whenOrNull(
              data: (value) =>
                  _renderSources(context, ref, value, currentSource),
            ) ??
        const SizedBox.shrink();
  }

  Widget _renderSources(
    BuildContext context,
    WidgetRef ref,
    List<MangaMediaItemSource> sources,
    String? currentSource,
  ) {
    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return SettingsSection(
      labelWidth: 400,
      label: Text(
        AppLocalizations.of(context)!.mangaTranslation,
        style: theme.textTheme.headlineSmall,
      ),
      section: Dropdown.button(
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
    );
  }
}

class _MangaReaderModeSelector extends ConsumerWidget {
  const _MangaReaderModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(mangaReaderModeSettingsProvider);

    return SettingsSection(
      labelWidth: 400,
      label: Text(
        AppLocalizations.of(context)!.mangaReaderMode,
        style: theme.textTheme.headlineSmall,
      ),
      section: Dropdown.button(
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
    );
  }
}
