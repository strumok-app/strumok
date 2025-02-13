import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/collection/sync/collection_sync_provider.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/widgets/focus_indicator.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';
import 'package:strumok/widgets/use_search_hint.dart';
import 'package:flutter/material.dart';

class ActiveCollectionItemsView extends ConsumerWidget {
  const ActiveCollectionItemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(collectionActiveItemsProvider);
    final collectionSync = ref.watch(collectionSyncStatusProvider).valueOrNull ?? false;

    if (collectionSync || groups.isLoading) {
      return _renderLoading(context);
    }

    return groups.maybeWhen(
      data: (value) => _ActiveCollectionItems(groups: value),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _renderLoading(BuildContext context) {
    return HorizontalList(
      title: FocusIndicator(
        child: Text(
          AppLocalizations.of(context)!.collectionContinue,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      itemBuilder: (context, index) => HorizontalListCard(
        onTap: () {},
        child: const Center(child: CircularProgressIndicator()),
      ),
      itemCount: 1,
    );
  }
}

class _ActiveCollectionItems extends ConsumerWidget {
  final Map<MediaCollectionItemStatus, List<MediaCollectionItem>> groups;

  const _ActiveCollectionItems({required this.groups});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<MediaCollectionItem>? items;
    String? title;

    if (groups.containsKey(MediaCollectionItemStatus.inProgress)) {
      items = groups[MediaCollectionItemStatus.inProgress]?.toList();
      title = AppLocalizations.of(context)!.collectionContinue;
    } else if (groups.containsKey(MediaCollectionItemStatus.latter)) {
      items = groups[MediaCollectionItemStatus.latter]?.toList();
      title = AppLocalizations.of(context)!.collectionBegin;
    }

    if (items == null) {
      return _renderEmptyCollection(context);
    }

    return HorizontalList(
      title: FocusIndicator(
        child: Text(
          title!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      itemBuilder: (context, index) {
        final item = items![index];

        return ContentInfoCard(
          key: Key("${item.supplier}/${item.id}"),
          contentInfo: item,
        );
      },
      itemCount: items.length,
    );
  }

  Widget _renderEmptyCollection(BuildContext context) {
    return HorizontalList(
      title: Text(
        AppLocalizations.of(context)!.collectionBegin,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, index) => HorizontalListCard(
        onTap: () {
          context.router.replace(const SearchRoute());
        },
        child: const UseSearchHint(),
      ),
      itemCount: 1,
    );
  }
}
