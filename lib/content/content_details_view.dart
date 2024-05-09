import 'package:cloud_hook/app_localizations.dart';
import 'package:cloud_hook/collection/collection_item_model.dart';
import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/collection/widgets/priority_selector.dart';
import 'package:cloud_hook/collection/widgets/status_selector.dart';
import 'package:cloud_hook/content/content_info_card.dart';
import 'package:cloud_hook/content/media_items_list.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/visual.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';

class ContentDetailsView extends ConsumerWidget {
  final ContentDetails contentDetails;

  const ContentDetailsView(this.contentDetails, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FastCachedImageProvider(contentDetails.image),
          alignment: Alignment.centerRight,
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Stack(
        children: [
          _renderGradient(context),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _renderMainInfo(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderGradient(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height,
      constraints: BoxConstraints(
        minWidth: mobileWidth,
        maxWidth: _calcMaxWidth(context),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: const [0, 0.9, 1.0],
          colors: [
            theme.colorScheme.background.withOpacity(0.5),
            theme.colorScheme.background.withOpacity(0.5),
            theme.colorScheme.background.withOpacity(0),
          ],
        ),
      ),
    );
  }

  double _calcMaxWidth(BuildContext context) {
    var maxWidth = isMobile(context)
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width * .5;

    if (maxWidth < mobileWidth) {
      maxWidth = mobileWidth;
    }

    return maxWidth;
  }

  Widget _renderMainInfo(BuildContext context) {
    final theme = Theme.of(context);
    final paddings = getPadding(context);
    final mobile = isMobile(context);

    return Container(
      padding: mobile ? EdgeInsets.all(paddings) : null,
      constraints: BoxConstraints(
        minWidth: mobileWidth,
        maxWidth: _calcMaxWidth(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText(
            contentDetails.title,
            style: theme.textTheme.headlineLarge?.copyWith(height: 1),
          ),
          SelectableText(
            contentDetails.oroginalTitle,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: paddings * 2),
          _ContentWatchButtons(contentDetails),
          _MediaCollectionItemButtons(contentDetails),
          SizedBox(height: paddings),
          _renderAdditionalInfo(),
          SizedBox(height: paddings),
          _renderDescription(context),
          SizedBox(height: paddings),
          if (contentDetails.similar.isNotEmpty) ..._renderSimilar(context)
        ],
      ),
    );
  }

  Widget _renderAdditionalInfo() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: contentDetails.additionalInfo
          .map((e) => Chip(label: Text("${e.name} ${e.value}")))
          .toList(),
    );
  }

  Widget _renderDescription(BuildContext context) {
    final theme = Theme.of(context);

    return ReadMoreText(
      contentDetails.description,
      trimMode: TrimMode.Line,
      trimLines: 4,
      trimCollapsedText: AppLocalizations.of(context)!.readMore,
      trimExpandedText: AppLocalizations.of(context)!.readLess,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  Iterable<Widget> _renderSimilar(BuildContext context) {
    final theme = Theme.of(context);
    final paddings = getPadding(context);

    return [
      Text(
        AppLocalizations.of(context)!.recomendations,
        style: theme.textTheme.headlineSmall,
      ),
      SizedBox(height: paddings),
      Wrap(
        children: contentDetails.similar
            .map(
              (e) => ContentInfoCard(
                contentInfo: e,
                onTap: () {
                  context.push("/content/${e.supplier}/${e.id}");
                },
              ),
            )
            .toList(),
      )
    ];
  }
}

class _ContentWatchButtons extends HookWidget {
  final ContentDetails contentDetails;

  const _ContentWatchButtons(this.contentDetails);

  @override
  Widget build(BuildContext context) {
    final paddings = getPadding(context);

    final mediaItemsFeature = useMemoized(() => contentDetails.mediaItems);
    final snapshot = useFuture(mediaItemsFeature);

    if (snapshot.connectionState == ConnectionState.waiting ||
        !snapshot.hasData) {
      return const SizedBox(height: 40);
    }

    final mediaItems = snapshot.data!;
    final showList = mediaItems.firstOrNull?.title.isNotEmpty ?? false;

    return Row(
      children: [
        _renderWatchButton(context),
        SizedBox(width: paddings),
        if (showList)
          _ContentPlaylistButton(
            contentDetails: contentDetails,
            mediaItems: mediaItems,
          )
      ],
    );
  }

  FilledButton _renderWatchButton(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {
        context.push("/video/${contentDetails.supplier}/${contentDetails.id}");
      },
      icon: const Icon(Icons.play_arrow_outlined),
      label: Text(AppLocalizations.of(context)!.watchButton),
    );
  }
}

class _ContentPlaylistButton extends ConsumerWidget {
  _ContentPlaylistButton({
    required this.contentDetails,
    required this.mediaItems,
  }) : provider = collectionItemProvider(contentDetails);

  final ContentDetails contentDetails;
  final Iterable<ContentMediaItem> mediaItems;
  final CollectionItemProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentItem = ref.watch(provider);

    return contentItem.maybeWhen(
      data: (data) => _renderButton(context, ref, data),
      orElse: () => _renderButton(context, ref, null),
    );
  }

  IconButton _renderButton(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem? collectionItem,
  ) {
    return IconButton(
      onPressed: () {
        final navigator = Navigator.of(context);
        navigator.push(
          MediaItemsListRoute(
            mediaItems: mediaItems,
            contentProgress: collectionItem,
            onSelect: (item) {
              ref.read(provider.notifier).setCurrentItem(item.number);
              context.push(
                  "/video/${contentDetails.supplier}/${contentDetails.id}");
            },
          ),
        );
      },
      icon: const Icon(Icons.list),
      tooltip: AppLocalizations.of(context)!.episodesList,
    );
  }
}

class _MediaCollectionItemButtons extends ConsumerWidget {
  _MediaCollectionItemButtons(ContentDetails contentDetails)
      : provider = collectionItemProvider(contentDetails);

  final CollectionItemProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ref.watch(provider).maybeWhen(
            data: (data) => _render(context, ref, data),
            orElse: () => const SizedBox(height: 40),
          ),
    );
  }

  Widget _render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem data,
  ) {
    final paddings = getPadding(context);

    return Row(
      children: [
        const SizedBox(height: 40),
        CollectionItemStatusSelector.button(
          collectionItem: data,
          onSelect: (status) {
            ref.read(provider.notifier).setStatus(status);
          },
        ),
        SizedBox(width: paddings),
        if (data.status != MediaCollectionItemStatus.none)
          CollectionItemPrioritySelector(
            collectionItem: data,
            onSelect: (priority) {
              ref.read(provider.notifier).setPriorit(priority);
            },
          )
      ],
    );
  }
}
