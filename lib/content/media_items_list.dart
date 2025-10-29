import 'package:cached_network_image/cached_network_image.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

typedef SelectCallback = void Function(ContentMediaItem);
typedef MediaItemsListBuilder =
    Widget Function(ContentMediaItem, ContentProgress?, SelectCallback);

class MediaItemsListRoute<T> extends PopupRoute<T> {
  final String title;
  final List<ContentMediaItem> mediaItems;
  final ContentProgress? contentProgress;
  final MediaItemsListBuilder itemBuilder;
  final SelectCallback onSelect;

  MediaItemsListRoute({
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
    required this.title,
    required this.mediaItems,
    this.contentProgress,
    required this.onSelect,
    required this.itemBuilder,
  });

  @override
  Color? get barrierColor => null;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dissmiss';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.ease;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: BackButtonListener(
        onBackButtonPressed: () async {
          Navigator.of(context).maybePop();
          return true;
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: SafeArea(
            child: _MediaItemsListView(
              title: title,
              mediaItems: mediaItems,
              contentProgress: contentProgress,
              onSelect: (item) {
                Navigator.of(context).pop();
                onSelect(item);
              },
              itemBuilder: itemBuilder,
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaItemsListView extends StatelessWidget {
  final String title;
  final List<ContentMediaItem> mediaItems;
  final ContentProgress? contentProgress;
  final SelectCallback onSelect;
  final MediaItemsListBuilder itemBuilder;

  const _MediaItemsListView({
    required this.title,
    required this.mediaItems,
    required this.contentProgress,
    required this.onSelect,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final mobile = isMobile(context);

    const radius = Radius.circular(10);

    return Container(
      padding: const EdgeInsets.all(8.0),
      width: mobileWidth * 0.7,
      height: size.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: mobile ? Radius.zero : radius,
          bottomLeft: mobile ? Radius.zero : radius,
        ),
      ),
      child: Material(
        child: Column(
          children: [
            _renderTitle(context),
            Expanded(
              child: _MediaItemsList(
                mediaItems: mediaItems,
                contentProgress: contentProgress,
                onSelect: onSelect,
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(title, style: theme.textTheme.headlineMedium),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

class _MediaItemsList extends StatefulWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentProgress? contentProgress;
  final SelectCallback onSelect;
  final MediaItemsListBuilder itemBuilder;

  const _MediaItemsList({
    required this.mediaItems,
    required this.contentProgress,
    required this.onSelect,
    required this.itemBuilder,
  });

  @override
  State<_MediaItemsList> createState() => _MediaItemsListState();
}

class _MediaItemsListState extends State<_MediaItemsList> {
  late final Map<String, List<ContentMediaItem>> groups;

  @override
  void initState() {
    groups = widget.mediaItems.groupListsBy((element) => element.section ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (groups.length == 1) {
      return _MediaItemsListSection(
        list: groups.values.first,
        contentProgress: widget.contentProgress,
        onSelect: widget.onSelect,
        itemBuilder: widget.itemBuilder,
      );
    }

    return DefaultTabController(
      initialIndex: _currentSectionIndex(groups),
      length: groups.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabs: groups.keys.map((e) => Tab(text: e)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: groups.values
                  .map(
                    (e) => _MediaItemsListSection(
                      list: e,
                      contentProgress: widget.contentProgress,
                      onSelect: widget.onSelect,
                      itemBuilder: widget.itemBuilder,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  int _currentSectionIndex(Map<String, dynamic> groups) {
    if (widget.contentProgress == null) {
      return 0;
    }

    final currentItem = widget.mediaItems[widget.contentProgress!.currentItem];
    return groups.keys.toList().indexOf(currentItem.section!);
  }
}

class _MediaItemsListSection extends StatefulWidget {
  final List<ContentMediaItem> list;
  final ContentProgress? contentProgress;
  final SelectCallback onSelect;
  final MediaItemsListBuilder itemBuilder;

  const _MediaItemsListSection({
    required this.list,
    required this.contentProgress,
    required this.onSelect,
    required this.itemBuilder,
  });

  @override
  State<_MediaItemsListSection> createState() => _MediaItemsListSectionState();
}

class _MediaItemsListSectionState extends State<_MediaItemsListSection> {
  late final int index;

  @override
  void initState() {
    final currentItem = widget.contentProgress?.currentItem ?? 0;
    final foundIndex = widget.list.indexWhere(
      (element) => element.number == currentItem,
    );

    index = foundIndex > 0 ? foundIndex - 1 : 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      initialScrollIndex: index,
      itemBuilder: (context, index) {
        final item = widget.list[index];

        return widget.itemBuilder(
          item,
          widget.contentProgress,
          widget.onSelect,
        );
      },
      itemCount: widget.list.length,
    );
  }
}

class MediaItemsListItem extends StatefulWidget {
  final ContentMediaItem item;
  final bool selected;
  final double progress;
  final VoidCallback onTap;
  final IconData selectIcon;
  final Widget? trailing;

  const MediaItemsListItem({
    super.key,
    required this.item,
    required this.selected,
    required this.selectIcon,
    required this.progress,
    required this.onTap,
    this.trailing,
  });

  @override
  State<MediaItemsListItem> createState() => _MediaItemsListItemState();
}

class _MediaItemsListItemState extends State<MediaItemsListItem> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.item.title;
    final image = widget.item.image;
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.surfaceTint.withValues(alpha: 0.5);
    final focusColor = focused ? colorScheme.onSurfaceVariant : accentColor;
    final backgroundColor = focused
        ? colorScheme.onSurface.withValues(alpha: 0.15)
        : Colors.transparent;
    final isTv = TVDetector.isTV;

    return Card.filled(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: focusColor),
      ),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image != null)
                GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: widget.selected
                        ? Center(
                            child: Icon(
                              widget.selectIcon,
                              color: Colors.white,
                              size: 48,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              Expanded(
                child: ListTile(
                  onTap: widget.onTap,
                  autofocus: widget.selected,
                  onFocusChange: (value) {
                    setState(() {
                      focused = value;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (image == null && widget.selected) ...[
                        const SizedBox(width: 8),
                        Icon(widget.selectIcon),
                      ],
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isTv && widget.trailing != null) widget.trailing!,
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: LinearProgressIndicator(value: widget.progress),
                  ),
                ),
              ),
              if (isTv && widget.trailing != null)
                Container(
                  color: accentColor,
                  child: Center(child: widget.trailing!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
