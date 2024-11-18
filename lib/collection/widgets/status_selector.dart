import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/widgets/dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef StatusSelectCallBack = Function(MediaCollectionItemStatus status);
typedef AnchorChildBuilder = Function(
  BuildContext context,
  VoidCallback onPressed,
  Widget? child,
);

class CollectionItemStatusSelector extends StatelessWidget {
  late final AnchorChildBuilder? anchorBuilder;
  late final Offset? alignmentOffset;
  final MediaCollectionItem collectionItem;
  final StatusSelectCallBack onSelect;

  @override
  Widget build(BuildContext context) {
    return Dropdown(
      anchorBuilder: anchorBuilder,
      alignmentOffset: alignmentOffset,
      menuChildrenBuilder: (focusNode) => _statusMenuItems(context, focusNode),
    );
  }

  List<Widget> _statusMenuItems(BuildContext context, FocusNode focusNode) {
    return [
      ...MediaCollectionItemStatus.values
          .where(
            (e) =>
                e != MediaCollectionItemStatus.none &&
                e != collectionItem.status,
          )
          .mapIndexed(
            (index, e) => MenuItemButton(
              focusNode: index == 0 ? focusNode : null,
              onPressed: () => onSelect(e),
              child: Text(statusMenuItemLabel(context, e)),
            ),
          ),
      if (collectionItem.status != MediaCollectionItemStatus.none)
        MenuItemButton(
          onPressed: () => onSelect(MediaCollectionItemStatus.none),
          child: Text(
            statusMenuItemLabel(context, MediaCollectionItemStatus.none),
          ),
        )
    ];
  }

  CollectionItemStatusSelector.button({
    super.key,
    required this.collectionItem,
    required this.onSelect,
  }) {
    anchorBuilder = (context, onPressed, child) => ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            collectionItem.status == MediaCollectionItemStatus.none
                ? Icons.favorite_border
                : Icons.favorite,
          ),
          label: Text(statusLabel(context, collectionItem.status)),
        );
    alignmentOffset = null;
  }

  CollectionItemStatusSelector.iconButton({
    super.key,
    required this.collectionItem,
    required this.onSelect,
  }) {
    anchorBuilder = (context, onPressed, child) => IconButton(
          onPressed: onPressed,
          icon: Icon(
            collectionItem.status == MediaCollectionItemStatus.none
                ? Icons.favorite_border
                : Icons.favorite,
          ),
        );

    alignmentOffset = const Offset(0, -120);
  }
}
