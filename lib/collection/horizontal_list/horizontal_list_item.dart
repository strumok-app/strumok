import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/collection/widgets/priority_selector.dart';
import 'package:strumok/collection/widgets/status_selector.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/utils/visual.dart';

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
      corner:
          cornerVisible.value
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
          child: _CollectionListItemCorner(item: item),
        ),
      ),
    );
  }
}

class _CollectionListItemCorner extends ConsumerWidget {
  const _CollectionListItemCorner({required this.item, this.focusNode});

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
