import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/utils/visual.dart';

class SourceSelector extends StatelessWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;

  const SourceSelector({
    super.key,
    required this.mediaItems,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _SourceSelectDialog(
            mediaItems: mediaItems,
            contentDetails: contentDetails,
          ),
        );
      },
      icon: const Icon(Icons.track_changes),
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class _SourceSelectDialog extends ConsumerWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;

  const _SourceSelectDialog({
    required this.mediaItems,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesDataAsync =
        ref.watch(collectionItemProvider(contentDetails).selectAsync((item) => (
              item.currentItem,
              item.currentSourceName,
              item.currentSubtitleName,
            )));

    return AppTheme(
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: FutureBuilder(
          future: sourcesDataAsync.then((rec) async {
            final (currentItem, currentSource, currentSubtitle) = rec;
            final sources = await mediaItems[currentItem].sources;

            return (sources, currentSource, currentSubtitle);
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 60,
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final (sources, currentSource, currentSubtitle) = snapshot.data!;

            final videos = sources.where((e) => e.kind == FileKind.video);
            final subtitles = sources.where((e) => e.kind == FileKind.subtitle);

            if (videos.isEmpty) {
              return Container(
                constraints: const BoxConstraints.tightFor(
                  height: 60,
                  width: 60,
                ),
                child: Center(
                  child: Text(AppLocalizations.of(context)!.videoNoSources),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < mobileWidth) {
                  return SingleChildScrollView(
                    child: Column(children: [
                      _renderVideoSources(context, ref, videos, currentSource),
                      if (subtitles.isNotEmpty)
                        _renderSubtitlesSources(
                            context, ref, subtitles, currentSubtitle),
                    ]),
                  );
                } else {
                  return FocusScope(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                            child: _renderVideoSources(
                                context, ref, videos, currentSource)),
                        if (subtitles.isNotEmpty)
                          SingleChildScrollView(
                            child: _renderSubtitlesSources(
                                context, ref, subtitles, currentSubtitle),
                          ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _renderVideoSources(
    BuildContext context,
    WidgetRef ref,
    Iterable<ContentMediaItemSource> sources,
    String? currentSourceName,
  ) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: sources
            .mapIndexed(
              (idx, e) => ListTile(
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.music_note),
                trailing: currentSourceName == e.description
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  final notifier =
                      ref.read(collectionItemProvider(contentDetails).notifier);
                  notifier.setCurrentSource(e.description);
                },
                title: Text(
                  e.description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                autofocus: idx == 0,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _renderSubtitlesSources(
    BuildContext context,
    WidgetRef ref,
    Iterable<ContentMediaItemSource> sources,
    String? currentSubtitleName,
  ) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.subtitles),
            trailing:
                currentSubtitleName == null ? const Icon(Icons.check) : null,
            onTap: () {
              final notifier =
                  ref.read(collectionItemProvider(contentDetails).notifier);
              notifier.setCurrentSubtitle(null);
              Navigator.of(context).pop();
            },
            title: Text(AppLocalizations.of(context)!.videoSubtitlesOff),
          ),
          ...sources.map(
            (e) => ListTile(
              visualDensity: VisualDensity.compact,
              leading: const Icon(Icons.subtitles),
              trailing: currentSubtitleName == e.description
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                final notifier =
                    ref.read(collectionItemProvider(contentDetails).notifier);
                notifier.setCurrentSubtitle(e.description);
                Navigator.of(context).pop();
              },
              title: Text(
                e.description,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          )
        ],
      ),
    );
  }
}
