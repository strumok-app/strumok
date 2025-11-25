import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/collection/widgets/priority_selector.dart';
import 'package:strumok/collection/widgets/status_selector.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/utils/visual.dart';

class CollectionHorizontalListItem extends ConsumerStatefulWidget {
  final MediaCollectionItem item;
  final bool autofocus;

  const CollectionHorizontalListItem({
    super.key,
    required this.item,
    required this.autofocus,
  });

  @override
  ConsumerState<CollectionHorizontalListItem> createState() =>
      _CollectionHorizontalListItemState();
}

class _CollectionHorizontalListItemState
    extends ConsumerState<CollectionHorizontalListItem> {
  final FocusNode itemActionsfocusNode = FocusNode();
  bool cornerVisible = false;

  @override
  void dispose() {
    itemActionsfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isDesktopDevice() ? _buildDesktop(context) : _buildNoMouse(context);
  }

  Widget _buildNoMouse(BuildContext context) {
    return ContentInfoCard(
      contentInfo: widget.item,
      onLongPress: () {
        setState(() {
          cornerVisible = !cornerVisible;
        });
        itemActionsfocusNode.requestFocus();
      },
      corner: cornerVisible
          ? BackButtonListener(
              onBackButtonPressed: () async {
                itemActionsfocusNode.previousFocus();
                return true;
              },
              child: _CollectionListItemCorner(
                item: widget.item,
                focusNode: itemActionsfocusNode,
              ),
            )
          : null,
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return ContentInfoCard(
      autofocus: widget.autofocus,
      contentInfo: widget.item,
      onHover: (value) {
        setState(() {
          cornerVisible = !cornerVisible;
        });
      },
      corner: AnimatedOpacity(
        opacity: cornerVisible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: _CollectionListItemCorner(item: widget.item),
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
