import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strumok/content/manga/intents.dart';
import 'package:strumok/content/manga/manga_page_image.dart';
import 'package:strumok/content/manga/manga_reader_controller.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/l10n/app_localizations.dart';
import 'package:strumok/widgets/zoom_view.dart';

class MangaLongStripViewer extends StatefulWidget {
  final MangaReaderMode readerMode;
  final MangaReaderState readerState;

  const MangaLongStripViewer({
    super.key,
    required this.readerMode,
    required this.readerState,
  });

  @override
  State<MangaLongStripViewer> createState() => _MangaLongStripViewerState();
}

class _MangaLongStripViewerState extends State<MangaLongStripViewer> {
  final Set<_PageElement> _registeredPageElement = {};

  final _zoomViewController = ZoomViewController();
  final _scrollController = ScrollController();
  late final AnimatedScrollController _animatedScrollController;
  final _focusNode = FocusNode(debugLabel: "manga_long_strip_viewer");

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

    final currentPage = widget.readerState.currentPage;

    _page = currentPage.value;
    _setWidgetKeys();

    currentPage.addListener(_handlePageChange);

    _scrollController.addListener(_handleScroll);
    _animatedScrollController = AnimatedScrollController(
      _scrollController,
      widget.readerMode.direction,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant MangaLongStripViewer oldWidget) {
    final currentPage = widget.readerState.currentPage;

    _page = currentPage.value;
    _setWidgetKeys();

    currentPage.addListener(_handlePageChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    final currentPage = widget.readerState.currentPage;

    currentPage.removeListener(_handlePageChange);

    _animatedScrollController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.readerMode.direction;

    return MangaReaderIteractions(
      readerMode: widget.readerMode,
      focusNode: _focusNode,
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.arrowLeft): ScrollUpIntent(
          page: true,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight): ScrollDownIntent(
          page: true,
        ),
        SingleActivator(LogicalKeyboardKey.arrowUp): ScrollUpIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): ScrollDownIntent(),
      },
      actions: {
        ScrollUpIntent: CallbackAction<ScrollUpIntent>(
          onInvoke: (indent) {
            if (indent.page) {
              _animatedScrollController.scrollScrean(context, false);
            } else {
              _animatedScrollController.scroll(context, false);
            }
            return null;
          },
        ),
        ScrollDownIntent: CallbackAction<ScrollDownIntent>(
          onInvoke: (indent) {
            if (indent.page) {
              _animatedScrollController.scrollScrean(context, true);
            } else {
              _animatedScrollController.scroll(context, true);
            }
            return null;
          },
        ),
        PrevMediaItemIntent: CallbackAction<PrevMediaItemIntent>(
          onInvoke: (_) => mangaReaderController(context).prevItem(),
        ),
        NextMediaItemIntent: CallbackAction<NextMediaItemIntent>(
          onInvoke: (_) => mangaReaderController(context).nextItem(),
        ),
      },
      child: Builder(
        builder: (context) {
          return ZoomView(
            maxScale: 5,
            minScale: .5,
            zoomViewController: _zoomViewController,
            onTap: () => Actions.invoke(context, ShowUIIntent()),
            onDoubleTap: (details) =>
                _zoomViewGestureHandler.onDoubleTap(details),
            scrollAxis: direction,
            controller: _scrollController,
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              center: _center,
              controller: _scrollController,
              scrollDirection: direction,
              slivers: [
                if (widget.readerState.hasPrev)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ChapterNav(
                        direction: direction,
                        label: AppLocalizations.of(context)!.mangaPrevItem,
                        onPressed: () =>
                            Actions.invoke(context, PrevMediaItemIntent()),
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
                    childCount: widget.readerState.pages.length - _page - 1,
                  ),
                ),
                if (widget.readerState.hasNext)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ChapterNav(
                        direction: direction,
                        label: AppLocalizations.of(context)!.mangaNextItem,
                        onPressed: () =>
                            Actions.invoke(context, NextMediaItemIntent()),
                      ),
                      childCount: 1,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handlePageChange() {
    final currentPage = widget.readerState.currentPage;

    final page = currentPage.value;

    if (_firstVisiablePage != page) {
      setState(() {
        _scrollController.jumpTo(0);
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
        direction: widget.readerMode.direction,
        page: widget.readerState.pages[index],
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

      final currentPage = widget.readerState.currentPage.value;
      if (firstPage != currentPage) {
        _firstVisiablePage = firstPage;

        widget.readerState.currentPage.value = firstPage;
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

    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      child: SizedBox(
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

class AnimatedScrollController {
  final ScrollController _controller;
  Axis _direction;

  static const animationTime = 200;

  DateTime _lastTimestamp = DateTime.timestamp();
  Timer? _timer;
  double _speed = 0;
  double _distanceLeftToScroll = 0;
  bool running = false;

  AnimatedScrollController(this._controller, this._direction);

  void scrollScrean(BuildContext context, bool forward) {
    final size = MediaQuery.of(context).size;
    final dist = _direction == Axis.vertical ? size.height : size.width;

    _scrollDist(forward, dist);
  }

  void scroll(BuildContext context, bool forward) {
    _scrollDist(forward, 200);
  }

  void _scrollDist(bool forward, double dist) {
    _distanceLeftToScroll = dist;
    _speed = _distanceLeftToScroll / animationTime;

    if (!forward) {
      _speed = -_speed;
    }

    _startScrolling();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  set direction(Axis d) {
    stop();
    _direction = d;
  }

  void _startScrolling() {
    if (_timer != null) {
      return;
    }

    _lastTimestamp = DateTime.timestamp();
    _timer = Timer.periodic(Duration(milliseconds: 16), _scroll);
  }

  void _scroll(Timer timer) {
    final timestamp = DateTime.timestamp();
    final timeElapsed = timestamp.difference(_lastTimestamp).inMilliseconds;
    _lastTimestamp = timestamp;

    final dist = _speed * timeElapsed;
    double targetPos = _controller.offset + dist;

    if (targetPos < _controller.position.minScrollExtent) {
      targetPos = _controller.position.minScrollExtent;
    } else if (targetPos > _controller.position.maxScrollExtent) {
      targetPos = _controller.position.maxScrollExtent;
    }

    _controller.jumpTo(targetPos);

    _distanceLeftToScroll -= dist.abs();

    if (_distanceLeftToScroll <= 0) {
      stop();
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
