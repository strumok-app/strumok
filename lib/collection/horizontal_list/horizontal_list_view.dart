import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/collection/horizontal_list/horizontal_list_item.dart';
import 'package:strumok/collection/sync/collection_sync_provider.dart';
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
    final collections = ref.watch(collectionItemsByStatusProvider).valueOrNull;
    final collectionSync =
        ref.watch(collectionSyncStatusProvider).valueOrNull ?? false;

    if (collectionSync) {
      return const Center(child: CircularProgressIndicator());
    }

    if (collections == null) {
      return const SizedBox.shrink();
    }

    if (collections.isEmpty) {
      return const UseSearchHint();
    }

    return ListView(
      children:
          groupsOrder.mapIndexed((groupIdx, e) {
            return CollectionHorizontalGroup(groupIdx: groupIdx, status: e);
          }).toList(),
    );
  }
}

class CollectionHorizontalGroup extends HookConsumerWidget {
  final MediaCollectionItemStatus status;
  final int groupIdx;

  const CollectionHorizontalGroup({
    super.key,
    required this.groupIdx,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryFocusNode = useFocusNode();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        primaryFocusNode.requestFocus();
      });
      return null;
    }, [primaryFocusNode]);

    final groupItems = ref.watch(
      collectionItemsByStatusProvider.select(
        (value) => value.valueOrNull?[status],
      ),
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
          key: ValueKey(item),
          focusNode: (groupIdx == 0 && index == 0) ? primaryFocusNode : null,
          item: groupItems[index],
        );
      },
      itemCount: groupItems.length,
    );
  }
}
