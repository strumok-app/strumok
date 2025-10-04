import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/utils/matrix.dart';

class MangaScrolledViewer extends StatefulWidget {
  final List<ImageProvider<Object>> pages;
  final Axis direction;
  final ScrollController scrollController;
  final ValueNotifier<int> pageListenable;

  const MangaScrolledViewer({
    super.key,
    required this.pages,
    required this.direction,
    required this.pageListenable,
    required this.scrollController,
  });

  @override
  State<MangaScrolledViewer> createState() => _MangaScrolledViewerState();
}

class _MangaScrolledViewerState extends State<MangaScrolledViewer> {
  final _transformationController = TransformationController();
  final Key _centerKey = UniqueKey();
  final Set<_PageElement> _registeredPageElement = {};

  bool _scaling = false;
  bool _scheduleUpdate = false;
  late int _page;
  int _firstVisiablePage = 0;

  void _handleTransformationChange() {
    final newScaling = _transformationController.value.isScaled();
    if (_scaling != newScaling) {
      if (mounted) {
        setState(() {
          _scaling = newScaling;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return _ReaderGestureDetector(
      transformationController: _transformationController,
      child: InteractiveViewer(
        transformationController: _transformationController,
        scaleEnabled: _scaling,
        panEnabled: _scaling,
        child: CustomScrollView(
          physics: _scaling
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          center: _centerKey,
          controller: widget.scrollController,
          scrollDirection: widget.direction,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildImage(_page - index - 1),
                childCount: _page,
              ),
            ),
            SliverList(
              key: _centerKey,
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildImage(_page + index),
                childCount: 1,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildImage(_page + index + 1),
                childCount: widget.pages.length - _page - 1,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                right: widget.direction == Axis.horizontal
                    ? size.width * 0.7
                    : 0,
                bottom: widget.direction == Axis.vertical
                    ? size.height * 0.7
                    : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _page = widget.pageListenable.value;
    widget.pageListenable.addListener(_handlePageChange);
    widget.scrollController.addListener(_handleScroll);
    _transformationController.addListener(_handleTransformationChange);

    super.initState();
  }

  @override
  void dispose() {
    widget.pageListenable.removeListener(_handlePageChange);
    widget.scrollController.removeListener(_handleScroll);
    _transformationController.removeListener(_handleTransformationChange);

    super.dispose();
  }

  void _handlePageChange() {
    final page = widget.pageListenable.value;

    if (_firstVisiablePage != page) {
      setState(() {
        widget.scrollController.jumpTo(0);
        _page = page;
      });
    }
  }

  void _handleScroll() {
    _calcVisiablePages();
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
      child: Image(
        fit: BoxFit.fitWidth,
        image: widget.pages[index],
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return ManagPageAspectContainer(
              direction: widget.direction,
              child: child,
            );
          }
          return MangaPagePlaceholder(direction: widget.direction);
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

class _ReaderGestureDetector extends StatefulWidget {
  final TransformationController transformationController;
  final Widget child;

  const _ReaderGestureDetector({
    required this.transformationController,
    required this.child,
  });

  @override
  State<_ReaderGestureDetector> createState() => _ReaderGestureDetectorState();
}

class _ReaderGestureDetectorState extends State<_ReaderGestureDetector> {
  TapDownDetails? _lastTapDetails;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
      valueListenable: widget.transformationController,
      builder: (context, value, child) {
        return GestureDetector(
          onDoubleTapDown: (details) => _lastTapDetails = details,
          onTapDown: (details) => _lastTapDetails = details,
          onDoubleTap: _toggleZoom,
          onTap: value.isScaled() ? null : _toggleUI,
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.transparent,
            child: widget.child,
          ),
        );
      },
    );
  }

  void _toggleUI() {
    Actions.invoke(context, const ShowUIIntent());
  }

  void _toggleZoom() {
    if (_lastTapDetails == null) {
      return;
    }

    final position = _lastTapDetails!.globalPosition;
    final transfomationController = widget.transformationController;

    if (!transfomationController.value.isIdentity()) {
      transfomationController.value = Matrix4.identity();
    } else {
      transfomationController.value = Matrix4.identity()
        ..translateByDouble(-position.dx, -position.dy, 0, 1)
        ..scaleByDouble(2.0, 2.0, 2.0, 1.0);
    }
  }
}
