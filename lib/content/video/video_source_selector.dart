import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_player_provider.dart';
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
    final sourceSelectorValue =
        ref.watch(sourceSelectorProvider(contentDetails, mediaItems));

    return Dialog(
      child: sourceSelectorValue.when(
        data: (data) {
          final (sources, currentSource, currentSubtitle) = data;

          return _SourceSelectorContent(
            sources: sources,
            contentDetails: contentDetails,
            currentSource: currentSource,
            currentSubtitle: currentSubtitle,
          );
        },
        loading: () => const SizedBox(
          width: 60,
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) =>
            Text(AppLocalizations.of(context)!.videoNoSources),
      ),
    );
  }
}

class _SourceSelectorContent extends StatelessWidget {
  const _SourceSelectorContent({
    required this.sources,
    required this.contentDetails,
    required this.currentSource,
    required this.currentSubtitle,
  });

  final List<ContentMediaItemSource> sources;
  final ContentDetails contentDetails;
  final String? currentSource;
  final String? currentSubtitle;

  @override
  Widget build(BuildContext context) {
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
              _VideoSources(
                contentDetails: contentDetails,
                sources: videos,
                currentSourceName: currentSource,
              ),
              if (subtitles.isNotEmpty)
                _SubtitleSources(
                  contentDetails: contentDetails,
                  sources: subtitles,
                  currentSubtitleName: currentSubtitle,
                ),
            ]),
          );
        } else {
          return FocusScope(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  child: _VideoSources(
                    contentDetails: contentDetails,
                    sources: videos,
                    currentSourceName: currentSource,
                  ),
                ),
                if (subtitles.isNotEmpty)
                  SingleChildScrollView(
                    child: _SubtitleSources(
                      contentDetails: contentDetails,
                      sources: subtitles,
                      currentSubtitleName: currentSubtitle,
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _SubtitleSources extends ConsumerWidget {
  const _SubtitleSources({
    required this.contentDetails,
    required this.sources,
    required this.currentSubtitleName,
  });

  final ContentDetails contentDetails;
  final Iterable<ContentMediaItemSource> sources;
  final String? currentSubtitleName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _VideoSources extends ConsumerWidget {
  const _VideoSources({
    required this.contentDetails,
    required this.sources,
    required this.currentSourceName,
  });

  final ContentDetails contentDetails;
  final Iterable<ContentMediaItemSource> sources;
  final String? currentSourceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  final notifier = ref.read(
                    collectionItemProvider(contentDetails).notifier,
                  );
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
}
