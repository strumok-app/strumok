import 'package:cached_network_image/cached_network_image.dart';
import 'package:strumok/utils/nav.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:strumok/widgets/nothing_to_show.dart';

class ContentInfoCard extends StatefulWidget {
  final FocusNode focusNode;
  final bool showSupplier;

  final ValueChanged<bool>? onHover;
  final GestureLongPressCallback? onLongPress;
  final Widget? corner;
  final ContentInfo contentInfo;
  final GestureTapCallback? onTap;

  ContentInfoCard({
    super.key,
    required this.contentInfo,
    this.corner,
    this.onTap,
    this.onHover,
    this.onLongPress,
    FocusNode? focusNode,
    this.showSupplier = true,
  }) : focusNode = focusNode ?? FocusNode(debugLabel: "ContentInfoCard");

  @override
  State<ContentInfoCard> createState() => _ContentInfoCardState();
}

class _ContentInfoCardState extends State<ContentInfoCard> {
  bool _focused = false;

  @override
  void initState() {
    if (!isMobileDevice()) {
      _focused = widget.focusNode.hasFocus;
      widget.focusNode.addListener(_handleFocusChange);
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _focused = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = _focused
        ? const TextStyle(color: Colors.black)
        : const TextStyle(color: Colors.white);

    return HorizontalListCard(
      key: Key("${widget.contentInfo.supplier}/${widget.contentInfo.id}"),
      focusNode: widget.focusNode,
      onTap:
          widget.onTap ??
          () => navigateToContentDetails(context, widget.contentInfo),
      onHover: widget.onHover,
      onLongPress: widget.onLongPress,
      background: CachedNetworkImage(
        imageUrl: widget.contentInfo.image,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorWidget: (context, url, error) => Center(child: NothingToShow()),
      ),
      corner: widget.corner,
      badge: widget.showSupplier
          ? Badge(
              label: Text(widget.contentInfo.supplier),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              backgroundColor: theme.colorScheme.primary,
              textColor: theme.colorScheme.onPrimary,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Container(
            constraints: BoxConstraints(maxWidth: 100),
            decoration: BoxDecoration(
              gradient: _focused
                  ? null
                  : LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      stops: [.5, 1.0],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
              color: _focused ? Colors.white : null,
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contentInfo.title,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                  maxLines: 2,
                ),
                if (widget.contentInfo.secondaryTitle != null)
                  Text(
                    widget.contentInfo.secondaryTitle!,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
