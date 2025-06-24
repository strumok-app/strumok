import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/manga/widgets.dart';

class MangaScrolledViewer extends StatefulWidget {
  final List<ImageProvider<Object>> pages;
  final ValueNotifier<int> pageListenable;
  final ScrollController scrollController;

  const MangaScrolledViewer({
    super.key,
    required this.pages,
    required this.pageListenable,
    required this.scrollController,
  });

  @override
  State<MangaScrolledViewer> createState() => _MangaScrolledViewerState();
}

class _MangaScrolledViewerState extends State<MangaScrolledViewer> {
  final Key _centerKey = UniqueKey();
  final Set<_PageElement> _registeredPageElement = {};

  Set<int> _visiablePages = {};
  bool _scheduleUpdate = false;
  late int _page;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      center: _centerKey,
      controller: widget.scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildImage(_page - index - 1),
            childCount: _page,
            addSemanticIndexes: false,
          ),
        ),
        SliverList(
          key: _centerKey,
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildImage(_page + index),
            childCount: widget.pages.length - _page,
            addSemanticIndexes: false,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _page = widget.pageListenable.value;
    widget.pageListenable.addListener(_handlePageChange);
    widget.scrollController.addListener(_handleScroll);

    super.initState();
  }

  @override
  void dispose() {
    widget.pageListenable.removeListener(_handlePageChange);
    widget.scrollController.removeListener(_handleScroll);

    super.dispose();
  }

  void _handlePageChange() {
    final page = widget.pageListenable.value;

    // if (!_visiablePages.contains(page)) {
    setState(() {
      _page = page;
    });
    // }
  }

  void _handleScroll() {
    _calcVisiablePages();
    // final lastVisPage = _visiablePages.lastOrNull;

    // if (lastVisPage != null) {
    //   widget.pageListenable.value = lastVisPage;
    // }

    // print(lastVisPage);
  }

  Widget buildImage(int index) {
    return _RegisterWidget(
      onMountChange: (mounted, el) {
        if (mounted) {
          _registeredPageElement.add(_PageElement(index, el));
        } else {
          _registeredPageElement.remove(_PageElement(index, el));
        }

        print(_registeredPageElement);

        // _calcVisiablePages();
      },
      child: Image(
        fit: BoxFit.fitWidth,
        image: widget.pages[index],
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return MangaPagePlaceholder(direction: Axis.vertical);
        },
      ),
    );
  }

  void _calcVisiablePages() {
    if (_scheduleUpdate) {
      return;
    }

    _scheduleUpdate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_registeredPageElement.isEmpty) {
        _scheduleUpdate = false;
        return;
      }

      final screanSize = MediaQuery.of(context).size;
      final viewport = Rect.fromLTWH(0, 0, screanSize.width, screanSize.height);
      final Set<int> newVisiablePages = {};

      for (final pe in _registeredPageElement) {
        final renderBox = pe.element.renderObject as RenderBox;
        final globalTL = renderBox.localToGlobal(
          renderBox.size.topLeft(Offset.zero),
        );
        final globalBR = renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
        );
        final drawRect = Rect.fromLTRB(
          globalTL.dx,
          globalTL.dy,
          globalBR.dx,
          globalBR.dy,
        );

        if (viewport.overlaps(drawRect)) {
          newVisiablePages.add(pe.page);
        }
      }

      _scheduleUpdate = false;
      _visiablePages = newVisiablePages;

      print("Vis: $_visiablePages");
    });
  }
}

class _PageElement extends Equatable {
  final int page;
  final Element element;

  const _PageElement(this.page, this.element);

  @override
  List<Object?> get props => [element];

  @override
  String toString() {
    return page.toString();
  }
}

typedef _MountCallback = void Function(bool, Element);

class _RegisterWidget extends ProxyWidget {
  final _MountCallback onMountChange;

  const _RegisterWidget({required this.onMountChange, required super.child});

  @override
  Element createElement() => _RegisterWidgetElement(this, onMountChange);
}

class _RegisterWidgetElement extends ProxyElement {
  final _MountCallback onMountChange;

  _RegisterWidgetElement(super.widget, this.onMountChange);

  @override
  void notifyClients(covariant ProxyWidget oldWidget) {}

  @override
  void mount(Element? parent, Object? newSlot) {
    onMountChange(true, this);
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    onMountChange(false, this);
    super.unmount();
  }
}
