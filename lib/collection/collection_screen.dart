import 'package:auto_route/annotations.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/collection/collection_top_bar.dart';
import 'package:strumok/collection/widgets/priority_selector.dart';
import 'package:strumok/collection/widgets/status_selector.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/focus_indicator.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:strumok/widgets/use_search_hint.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 2,
      child: Column(
        children: [
          CollectionTopBar(),
          Expanded(child: CollectionHorizontalView()),
        ],
      ),
    );
  }
}

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
    final collections = ref.watch(collectionProvider).valueOrNull;

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
      collectionProvider.select((value) => value.valueOrNull?[status]),
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

class CollectionHorizontalListItem extends HookConsumerWidget {
  final MediaCollectionItem item;
  final FocusNode? focusNode;

  const CollectionHorizontalListItem({
    super.key,
    required this.item,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isDesktopDevice()
        ? _buildDesktop(context, ref)
        : _buildNoMouse(context, ref);
  }

  Widget _buildNoMouse(BuildContext context, WidgetRef ref) {
    final itemActionsfocusNode = useFocusNode();
    final cornerVisible = useState(false);

    return ContentInfoCard(
      focusNode: focusNode,
      contentInfo: item,
      onLongPress: () {
        cornerVisible.value = !cornerVisible.value;
        itemActionsfocusNode.requestFocus();
      },
      corner: cornerVisible.value
          ? BackButtonListener(
              onBackButtonPressed: () async {
                itemActionsfocusNode.previousFocus();
                return true;
              },
              child: _CollectionListItemCorner(
                item: item,
                focusNode: itemActionsfocusNode,
              ),
            )
          : null,
    );
  }

  Widget _buildDesktop(BuildContext context, WidgetRef ref) {
    final cornerVisible = useState(false);

    return ContentInfoCard(
      focusNode: focusNode,
      contentInfo: item,
      onHover: (value) {
        cornerVisible.value = value;
      },
      corner: ExcludeFocus(
        child: AnimatedOpacity(
          opacity: cornerVisible.value ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: _CollectionListItemCorner(
            item: item,
          ),
        ),
      ),
    );
  }
}

class _CollectionListItemCorner extends ConsumerWidget {
  const _CollectionListItemCorner({
    required this.item,
    this.focusNode,
  });

  final MediaCollectionItem item;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(40),
      ),
      child: FocusScope(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(
              // focus reciver
              focusNode: focusNode,
              child: const SizedBox(),
            ),
            CollectionItemPrioritySelector(
              collectionItem: item,
              onSelect: (priority) {
                ref
                    .read(collectionServiceProvider)
                    .save(item.copyWith(priority: priority));
              },
            ),
            CollectionItemStatusSelector.iconButton(
              collectionItem: item,
              onSelect: (status) {
                ref
                    .read(collectionServiceProvider)
                    .save(item.copyWith(status: status));
              },
            ),
          ],
        ),
      ),
    );
  }
}
