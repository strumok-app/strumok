import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/offline/media_item_download_provider.dart';
import 'package:strumok/offline/offline_content_details.dart';
import 'package:strumok/offline/offline_items_screen_provider.dart';
import 'package:strumok/offline/offline_storage.dart';

class MediaItemDownloadButton extends ConsumerWidget {
  final ContentDetails contentDetails;
  final ContentMediaItem item;

  const MediaItemDownloadButton({super.key, required this.contentDetails, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = mediaItemDownloadProvider(
      contentDetails.supplier,
      contentDetails.id,
      item.number,
    );
    final state = ref.watch(provider).valueOrNull;

    if (state == null) {
      return const SizedBox.shrink();
    }

    return switch (state.status) {
      MediaItemDownloadStatus.notStored => IconButton(
          onPressed: () => _showDialog(context),
          icon: Icon(Icons.file_download),
        ),
      MediaItemDownloadStatus.stored => IconButton(
          padding: EdgeInsets.all(8),
          onPressed: () => _showDialog(context),
          icon: Icon(Symbols.folder_check),
        ),
      MediaItemDownloadStatus.downloading => _MediaItemDownloadIndicator(
          state: state,
          onCancel: () {
            DownloadManager().cancel(state.downloadTask!.request.id);
          },
        ),
    };
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MediaItemDownloadDailog(
        contentDetails: contentDetails,
        item: item,
      ),
    );
  }
}

class _MediaItemDownloadIndicator extends StatelessWidget {
  final VoidCallback onCancel;

  const _MediaItemDownloadIndicator({
    required this.state,
    required this.onCancel,
  });

  final MediaItemDownloadState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 40,
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: state.downloadTask!.progress,
              builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    value: value,
                    backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                );
              },
            ),
            IconButton(
              padding: EdgeInsets.all(8),
              onPressed: onCancel,
              icon: Icon(Icons.cancel_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaItemDownloadDailog extends ConsumerWidget {
  final ContentDetails contentDetails;
  final ContentMediaItem item;

  const MediaItemDownloadDailog({
    super.key,
    required this.contentDetails,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: FutureBuilder(
        future: Future.value(item.sources),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const SizedBox(
              width: 60,
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final sources = snapshot.data!.where(
            (it) => it.kind == FileKind.video || it.kind == FileKind.manga,
          );

          if (sources.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(AppLocalizations.of(context)!.videoNoSources),
            );
          }

          final supplier = contentDetails.supplier;
          final id = contentDetails.id;
          final number = item.number;

          return Container(
            width: 320,
            constraints: BoxConstraints(maxHeight: 600),
            child: _SourceList(
              sources: sources,
              onDownload: (source) async {
                await OfflineStorage().storeSource(contentDetails, number, source);
                ref.invalidate(mediaItemDownloadProvider(supplier, id, number));
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              onDelete: (source) async {
                await OfflineStorage().deleteSource(supplier, id, number, source);
                ref.invalidate(mediaItemDownloadProvider(supplier, id, number));
                ref.invalidate(offlineContentProvider);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

typedef _SourceCallback = void Function(ContentMediaItemSource);

class _SourceList extends ConsumerWidget {
  final _SourceCallback onDownload;
  final _SourceCallback onDelete;
  final Iterable<ContentMediaItemSource> sources;

  const _SourceList({
    required this.sources,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: sources.map(_buildListItem).toList(),
      ),
    );
  }

  ListTile _buildListItem(source) {
    final avalaibleOffline = _isOffline(source);
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16, right: 8),
      visualDensity: VisualDensity.compact,
      leading: Icon(_getIconData(source)),
      trailing: avalaibleOffline
          ? IconButton(
              onPressed: () => onDelete(source),
              icon: const Icon(Icons.delete_outline),
            )
          : IconButton(
              onPressed: () => onDownload(source),
              icon: const Icon(Icons.download),
            ),
      title: Text(
        source.description,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  IconData _getIconData(ContentMediaItemSource source) {
    return switch (source.kind) {
      FileKind.video => Icons.video_file,
      FileKind.subtitle => Icons.subtitles,
      FileKind.manga => Icons.image_outlined,
    };
  }

  bool _isOffline(source) => source is OfflineContenItemSource;
}
