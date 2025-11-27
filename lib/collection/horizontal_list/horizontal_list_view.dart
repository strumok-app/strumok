import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/collection/horizontal_list/horizontal_list_item.dart';
import 'package:strumok/widgets/focus_indicator.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:strumok/widgets/use_search_hint.dart';

const groupsOrder = [
  MediaCollectionItemStatus.inProgress,
  MediaCollectionItemStatus.latter,
  MediaCollectionItemStatus.onHold,
  MediaCollectionItemStatus.complete,
];

class CollectionHorizontalView extends ConsumerWidget {
  const CollectionHorizontalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionItemsByStatusProvider).value;

    if (collections == null) {
      return const SizedBox.shrink();
    }

    if (collections.isEmpty) {
      return const UseSearchHint();
    }

    return ListView(
      children: groupsOrder.mapIndexed((groupIdx, e) {
        return CollectionHorizontalGroup(groupIdx: groupIdx, status: e);
      }).toList(),
    );
  }
}

class CollectionHorizontalGroup extends ConsumerWidget {
  final MediaCollectionItemStatus status;
  final int groupIdx;

  const CollectionHorizontalGroup({
    super.key,
    required this.groupIdx,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupItems = ref.watch(
      collectionItemsByStatusProvider.select((value) => value.value?[status]),
    );

    if (groupItems == null) {
      return const SizedBox.shrink();
    }

    Widget title = Text(
      statusLabel(context, status),
      style: Theme.of(context).textTheme.titleMedium,
    );

    if (groupIdx == 0) {
      title = FocusIndicator(child: title);
    }

    return HorizontalList(
      title: title,
      itemBuilder: (context, index) {
        final item = groupItems[index];
        return CollectionHorizontalListItem(
          key: ValueKey("${item.supplier}/${item.id}"),
          item: groupItems[index],
          autofocus: (groupIdx == 0 && index == 0),
        );
      },
      itemCount: groupItems.length,
    );
  }
}
