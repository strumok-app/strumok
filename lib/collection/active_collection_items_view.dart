import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';
import 'package:strumok/widgets/use_search_hint.dart';
import 'package:flutter/material.dart';

class ActiveCollectionItemsView extends ConsumerWidget {
  const ActiveCollectionItemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(collectionActiveItemsProvider);

    return groups.maybeWhen(
      data: (value) => _renderGroups(context, value),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _renderGroups(BuildContext context,
      Map<MediaCollectionItemStatus, List<MediaCollectionItem>> groups) {
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
      title: Focus(
        child: Text(
          title!,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      itemBuilder: (context, index) {
        final item = items![index];

        return ContentInfoCard(
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
