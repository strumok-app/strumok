import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/details/content_details_actions.dart';
import 'package:strumok/content/media_items_list.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:strumok/download/media_item_download.dart';
import 'package:strumok/utils/nav.dart';

class ContentDetailsVideoActions extends ContentDetailsActions {
  const ContentDetailsVideoActions(super.contentDetails, {super.key});

  @override
  Widget renderActions(
    BuildContext context,
    List<ContentMediaItem> mediaItems,
  ) {
    final showList = mediaItems.firstOrNull?.title.isNotEmpty ?? false;

    return Row(
      children: [
        _renderWatchButton(context),
        const SizedBox(width: 8),
        showList
            ? _ContentPlaylistButton(
                contentDetails: contentDetails,
                mediaItems: mediaItems,
              )
            : MediaItemDownloadButton(
                contentDetails: contentDetails,
                item: mediaItems.first,
              ),
      ],
    );
  }

  Widget _renderWatchButton(BuildContext context) {
    return SizedBox(
      width: 200,
      child: OutlinedButton.icon(
        autofocus: true,
        onPressed: () => navigateToContent(context, contentDetails),
        icon: const Icon(Icons.play_arrow_outlined),
        label: Text(AppLocalizations.of(context)!.watchButton),
      ),
    );
  }
}

class _ContentPlaylistButton extends ConsumerWidget {
  _ContentPlaylistButton({
    required this.contentDetails,
    required this.mediaItems,
  }) : provider = collectionItemProvider(contentDetails);

  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final CollectionItemProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentItem = ref.watch(provider);

    return contentItem.maybeWhen(
      data: (data) => _renderButton(context, ref, data),
      orElse: () => const SizedBox.shrink(),
    );
  }

  IconButton _renderButton(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem? collectionItem,
  ) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MediaItemsListRoute(
            title: AppLocalizations.of(context)!.episodesList,
            mediaItems: mediaItems,
            contentProgress: collectionItem,
            onSelect: (item) {
              ref.read(provider.notifier).setCurrentItem(item.number);
              navigateToContent(context, contentDetails);
            },
            itemBuilder: playlistItemBuilder(contentDetails),
          ),
        );
      },
      icon: const Icon(Icons.list),
      tooltip: AppLocalizations.of(context)!.episodesList,
    );
  }
}
