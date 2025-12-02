import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/manga_page_image.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/widgets/zoom_view.dart';

class MangaLongStripViewer extends StatefulWidget {
  final List<MangaPageInfo> pages;
  final Axis direction;
  final ScrollController scrollController;
  final ValueNotifier<int> pageListenable;
  final bool hasPrevChapter;
  final bool hasNextChapter;

  const MangaLongStripViewer({
    super.key,
    required this.pages,
    required this.direction,
    required this.pageListenable,
    required this.scrollController,
    required this.hasPrevChapter,
    required this.hasNextChapter,
  });

  @override
  State<MangaLongStripViewer> createState() => _MangaLongStripViewerState();
}

class _MangaLongStripViewerState extends State<MangaLongStripViewer> {
  final Set<_PageElement> _registeredPageElement = {};
  final ZoomViewController _zoomViewController = ZoomViewController();
  late final ZoomViewGestureHandler _zoomViewGestureHandler;

  bool _scheduleUpdate = false;
  late int _page;
  int _firstVisiablePage = 0;

  late Key _top;
  late Key _center;
  late Key _bottom;

  @override
  void initState() {
    _zoomViewGestureHandler = ZoomViewGestureHandler(
      zoomLevels: [2, 1],
      controller: _zoomViewController,
    );
    _page = widget.pageListenable.value;
    _setWidgetKeys();

    widget.pageListenable.addListener(_handlePageChange);
    widget.scrollController.addListener(_handleScroll);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant MangaLongStripViewer oldWidget) {
    oldWidget.pageListenable.removeListener(_handlePageChange);
    oldWidget.scrollController.removeListener(_handleScroll);

    _page = widget.pageListenable.value;
    _setWidgetKeys();

    widget.pageListenable.addListener(_handlePageChange);
    widget.scrollController.addListener(_handleScroll);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.pageListenable.removeListener(_handlePageChange);
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomView(
      maxScale: 5,
      minScale: .5,
      zoomViewController: _zoomViewController,
      onTap: () => Actions.invoke(context, ShowUIIntent()),
      onDoubleTap: (details) => _zoomViewGestureHandler.onDoubleTap(details),
      scrollAxis: widget.direction,
      controller: widget.scrollController,
      child: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        center: _center,
        controller: widget.scrollController,
        scrollDirection: widget.direction,
        slivers: [
          if (widget.hasPrevChapter)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ChapterNav(
                  direction: widget.direction,
                  label: AppLocalizations.of(context)!.mangaPrevItem,
                  onPressed: () => Actions.invoke(context, PrevChapterIntent()),
                ),
                childCount: 1,
              ),
            ),
          SliverList(
            key: _top,
            delegate: SliverChildBuilderDelegate(
              (context, index) => buildImage(_page - index - 1),
              childCount: _page,
            ),
          ),
          SliverList(
            key: _center,
            delegate: SliverChildBuilderDelegate(
              (context, index) => buildImage(_page + index),
              childCount: 1,
            ),
          ),
          SliverList(
            key: _bottom,
            delegate: SliverChildBuilderDelegate(
              addRepaintBoundaries: true,
              (context, index) => buildImage(_page + index + 1),
              childCount: widget.pages.length - _page - 1,
            ),
          ),
          if (widget.hasNextChapter)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ChapterNav(
                  direction: widget.direction,
                  label: AppLocalizations.of(context)!.mangaNextItem,
                  onPressed: () => Actions.invoke(context, NextChapterIntent()),
                ),
                childCount: 1,
              ),
            ),
        ],
      ),
    );
  }

  void _handlePageChange() {
    final page = widget.pageListenable.value;

    if (_firstVisiablePage != page) {
      setState(() {
        widget.scrollController.jumpTo(0);
        _page = page;
        _setWidgetKeys();
      });
    }
  }

  void _handleScroll() {
    _calcVisiablePages();
  }

  void _setWidgetKeys() {
    _top = Key("top$_page");
    _center = Key("center$_page");
    _bottom = Key("bottom$_page");
  }

  Widget buildImage(int index) {
    return _RegisterWidget(
      onMountChange: (mounted, el) {
        if (mounted) {
          _registeredPageElement.add(_PageElement(index, el));
        } else {
          _registeredPageElement.remove(_PageElement(index, el));
        }
      },
      child: MangaPageImage(
        direction: widget.direction,
        page: widget.pages[index],
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
      final Set<int> sortedVisiablePages = SplayTreeSet();

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
          sortedVisiablePages.add(pe.page);
        }
      }

      _scheduleUpdate = false;

      var revVisiablePages = sortedVisiablePages.toList().reversed;
      var firstPage = revVisiablePages.first;
      for (final p in revVisiablePages) {
        if (p == firstPage - 1 || p == firstPage) {
          firstPage = p;
        } else {
          break;
        }
      }

      final currentPage = widget.pageListenable.value;
      if (firstPage != currentPage) {
        _firstVisiablePage = firstPage;

        widget.pageListenable.value = firstPage;
      }
    });
  }
}

class _ChapterNav extends StatelessWidget {
  final Axis direction;
  final String label;
  final VoidCallback? onPressed;

  const _ChapterNav({
    required this.direction,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: direction == Axis.vertical ? size.width : size.width * 0.5,
      height: direction == Axis.vertical ? size.height * 0.5 : size.height,
      child: Align(
        alignment: AlignmentGeometry.bottomRight,
        child: Center(
          child: TextButton(
            onPressed: onPressed,
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 32)),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
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
