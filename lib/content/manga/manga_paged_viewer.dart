import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/content/manga/widgets.dart';

class MangaPagedViewer extends ConsumerStatefulWidget {
  final List<ImageProvider<Object>> pages;
  final Axis direction;
  final TransformationController transformationController;
  final ValueListenable<int> pageListenable;

  const MangaPagedViewer({
    super.key,
    required this.pages,
    required this.direction,
    required this.transformationController,
    required this.pageListenable,
  });

  @override
  ConsumerState<MangaPagedViewer> createState() => _PagedViewState();
}

class _PagedViewState extends ConsumerState<MangaPagedViewer> {
  PageController? _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.pageListenable.value);
    widget.pageListenable.addListener(_onPageChanged);

    super.initState();
  }

  @override
  void dispose() {
    widget.pageListenable.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final pageNum = widget.pageListenable.value;
    final pages = widget.pages;

    precacheImage(pages[pageNum], context);
    for (int i = 1; i < 2; i++) {
      final r = pageNum + i;
      final l = pageNum - i;

      if (r < pages.length) {
        precacheImage(pages[r], context);
      }

      if (l >= 0) {
        precacheImage(pages[l], context);
      }
    }

    _pageController?.animateToPage(
      pageNum,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _SinglePageView(
          direction: widget.direction,
          page: widget.pages[index],
          transformationController: widget.transformationController,
        );
      },
      itemCount: widget.pages.length,
      scrollDirection: widget.direction,
    );
  }
}

class _SinglePageView extends ConsumerWidget {
  final ImageProvider<Object> page;
  final Axis direction;
  final TransformationController transformationController;

  const _SinglePageView({
    required this.page,
    required this.direction,
    required this.transformationController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 1,
          transformationController: transformationController,
          boundaryMargin: EdgeInsets.zero,
          child: MangaPageImage(
            direction: direction,
            constraints: constraints,
            page: page,
          ),
        );
      },
    );
  }
}
