import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';
import 'package:strumok/widgets/use_search_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActiveCollectionItemsView extends ConsumerWidget {
  const ActiveCollectionItemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(collectionActiveItemsProvider).valueOrNull ?? {};

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
          autofocus: index == 0,
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
          context.go("/search");
        },
        child: const UseSearchHint(),
      ),
      itemCount: 1,
    );
  }
}
