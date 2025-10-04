import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/utils/visual.dart';

class SourceSelector extends StatelessWidget {
  const SourceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final vcc = videoContentController(context);
    final contentDetails = vcc.contentDetails;
    final mediaItems = vcc.mediaItems;

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
      tooltip: AppLocalizations.of(context)!.videoPlayerBtnHintServers,
      icon: const Icon(Icons.cloud),
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.7),
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
    final sourceSelectorValue = ref.watch(
      sourceSelectorProvider(contentDetails, mediaItems),
    );

    return Dialog(
      child: sourceSelectorValue.when(
        data: (model) {
          return _SourceSelectorContent(
            contentDetails: contentDetails,
            model: model,
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
    required this.contentDetails,
    required this.model,
  });

  final ContentDetails contentDetails;
  final SourceSelectorModel model;

  @override
  Widget build(BuildContext context) {
    final videos = model.sources.where((e) => e.kind == FileKind.video);
    final subtitles = model.sources.where((e) => e.kind == FileKind.subtitle);

    if (videos.isEmpty) {
      return Container(
        constraints: const BoxConstraints.tightFor(height: 60, width: 60),
        child: Center(
          child: Text(AppLocalizations.of(context)!.videoNoSources),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileWidth) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _VideoSources(
                  contentDetails: contentDetails,
                  sources: videos,
                  currentSourceName: model.currentSource,
                ),
                if (subtitles.isNotEmpty)
                  _SubtitleSources(
                    contentDetails: contentDetails,
                    sources: subtitles,
                    currentSubtitleName: model.currentSubtitle,
                  ),
              ],
            ),
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
                    currentSourceName: model.currentSource,
                  ),
                ),
                if (subtitles.isNotEmpty)
                  SingleChildScrollView(
                    child: _SubtitleSources(
                      contentDetails: contentDetails,
                      sources: subtitles,
                      currentSubtitleName: model.currentSubtitle,
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
    return _SourcesList(
      sources: sources,
      currentSourceName: currentSourceName,
      onSelect: (source) {
        Navigator.of(context).pop();
        final notifier = ref.read(
          collectionItemProvider(contentDetails).notifier,
        );
        notifier.setCurrentSource(source.description);
      },
      sourceIcon: const Icon(Icons.video_file_outlined),
      autofocus: true,
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
    return _SourcesList(
      sources: sources,
      currentSourceName: currentSubtitleName,
      onSelect: (source) {
        Navigator.of(context).pop();
        final notifier = ref.read(
          collectionItemProvider(contentDetails).notifier,
        );
        notifier.setCurrentSubtitle(source.description);
      },
      sourceIcon: const Icon(Icons.subtitles),
      leading: ListTile(
        visualDensity: VisualDensity.compact,
        leading: const Icon(Icons.subtitles),
        trailing: currentSubtitleName == null ? const Icon(Icons.check) : null,
        onTap: () {
          final notifier = ref.read(
            collectionItemProvider(contentDetails).notifier,
          );
          notifier.setCurrentSubtitle(null);
          Navigator.of(context).pop();
        },
        title: Text(AppLocalizations.of(context)!.videoSubtitlesOff),
      ),
    );
  }
}

typedef _SourceCallback = void Function(ContentMediaItemSource source);

class _SourcesList extends ConsumerWidget {
  const _SourcesList({
    required this.sources,
    required this.currentSourceName,
    required this.onSelect,
    this.leading,
    this.sourceIcon,
    this.autofocus = false,
  });

  final Iterable<ContentMediaItemSource> sources;
  final String? currentSourceName;
  final _SourceCallback onSelect;
  final Widget? leading;
  final Widget? sourceIcon;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) leading!,
          ...sources.mapIndexed(
            (idx, source) => ListTile(
              visualDensity: VisualDensity.compact,
              leading: sourceIcon,
              trailing: currentSourceName == source.description
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => onSelect(source),
              title: Text(
                source.description,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              autofocus: autofocus && idx == 0,
            ),
          ),
        ],
      ),
    );
  }
}
