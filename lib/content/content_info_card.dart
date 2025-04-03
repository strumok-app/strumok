import 'package:cached_network_image/cached_network_image.dart';
import 'package:strumok/utils/nav.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

class ContentInfoCard extends StatelessWidget {
  final FocusNode? focusNode;
  final bool showSupplier;

  final ValueChanged<bool>? onHover;
  final GestureLongPressCallback? onLongPress;
  final Widget? corner;
  final ContentInfo contentInfo;
  final GestureTapCallback? onTap;

  const ContentInfoCard({
    super.key,
    required this.contentInfo,
    this.corner,
    this.onTap,
    this.onHover,
    this.onLongPress,
    this.focusNode,
    this.showSupplier = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HorizontalListCard(
      focusNode: focusNode,
      onTap: onTap ?? () => navigateToContentDetails(context, contentInfo),
      onHover: onHover,
      onLongPress: onLongPress,
      background: CachedNetworkImage(
        imageUrl: contentInfo.image,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
      corner: corner,
      badge:
          showSupplier
              ? Badge(
                label: Text(contentInfo.supplier),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                backgroundColor: theme.colorScheme.primary,
                textColor: theme.colorScheme.onPrimary,
              )
              : null,
      child: Column(
        children: [
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                stops: [.5, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              title: Text(
                contentInfo.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, inherit: true),
                maxLines: 2,
              ),
              subtitle:
                  contentInfo.secondaryTitle == null
                      ? null
                      : Text(
                        contentInfo.secondaryTitle!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          inherit: true,
                        ),
                        maxLines: 2,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
