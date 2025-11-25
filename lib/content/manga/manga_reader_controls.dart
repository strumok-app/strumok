import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/manga_reader_settings_dialog.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/utils/fullscrean.dart';
import 'package:strumok/utils/tv.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/utils/visual.dart';

class MangaReaderControlsRoute<T> extends PopupRoute<T> {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueNotifier<int> pagesController;

  MangaReaderControlsRoute({
    required this.contentDetails,
    required this.mediaItems,
    required this.pagesController,
  });

  @override
  Color? get barrierColor => Colors.transparent;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dissmiss';
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SafeArea(
        child: MangaReaderControls(
          contentDetails: contentDetails,
          mediaItems: mediaItems,
          pagesController: pagesController,
        ),
      ),
    );
  }
}

class MangaReaderControls extends StatelessWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueNotifier<int> pagesController;

  const MangaReaderControls({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.pagesController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        Navigator.of(context).pop();
      },
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            MangaReaderControlTopBar(
              contentDetails: contentDetails,
              mediaItems: mediaItems,
            ),
            const Spacer(),
            MangaReaderControlBottomBar(
              contentDetails: contentDetails,
              mediaItems: mediaItems,
              pagesController: pagesController,
            ),
          ],
        ),
      ),
    );
  }
}

class MangaReaderControlTopBar extends ConsumerWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const MangaReaderControlTopBar({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mobile = isMobile(context);

    final item = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .valueOrNull;

    return Container(
      color: Colors.black45,
      child: Padding(
        padding: EdgeInsets.only(
          left: mobile ? 8 : 20,
          right: 8,
          bottom: 8,
          top: 8,
        ),
        child: Row(
          children: [
            if (!TVDetector.isTV && !mobile) ...[
              BackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                color: Colors.white,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                [
                  contentDetails.title,
                  if (item != null) mediaItems[item].title,
                ].join(" - "),
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
              ),
            ),
            const Spacer(),
            _renderVolumesBotton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _renderVolumesBotton(BuildContext context, WidgetRef ref) {
    return VolumesButton(
      contentDetails: contentDetails,
      mediaItems: mediaItems,
      onSelect: (item) {
        ref
            .read(collectionItemProvider(contentDetails).notifier)
            .setCurrentItem(item.number);
        Navigator.of(context).pop();
      },
      autofocus: true,
      color: Colors.white,
    );
  }
}

class MangaReaderControlBottomBar extends ConsumerWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;
  final ValueNotifier<int> pagesController;

  const MangaReaderControlBottomBar({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.pagesController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final provider = collectionItemCurrentMediaItemPositionProvider(
      contentDetails,
    );
    final position = ref.watch(provider).value;

    if (position == null) {
      return const SizedBox.shrink();
    }

    final pageNumbers = position.length;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(navigationMode: NavigationMode.directional),
      child: Container(
        color: Colors.black45,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ValueListenableBuilder(
                valueListenable: pagesController,
                builder: (context, pageIndex, child) {
                  final pageNumber = pageIndex + 1;
                  return Text(
                    "$pageNumber / $pageNumbers",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
                  );
                },
              ),
              pageNumbers > 1
                  ? Expanded(
                      child: MangaPagesSlider(
                        pageNumbers: pageNumbers,
                        pagesController: pagesController,
                      ),
                    )
                  : Spacer(),
              MangaSettingsButton(
                contentDetails: contentDetails,
                mediaItems: mediaItems,
                color: Colors.white,
              ),
              if (isDesktopDevice()) ...[
                IconButton(
                  onPressed: toggleFullscreen,
                  icon: const Icon(Icons.fullscreen),
                  color: Colors.white,
                ),
                SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MangaPagesSlider extends StatefulWidget {
  final int pageNumbers;
  final ValueNotifier<int> pagesController;

  const MangaPagesSlider({
    super.key,
    required this.pageNumbers,
    required this.pagesController,
  });

  @override
  State<MangaPagesSlider> createState() => _MangaPagesSliderState();
}

class _MangaPagesSliderState extends State<MangaPagesSlider> {
  int? tragetPage;

  @override
  Widget build(BuildContext context) {
    final pageIndex = tragetPage ?? widget.pagesController.value;
    final pageNumber = pageIndex + 1;

    return SliderTheme(
      data: SliderThemeData(tickMarkShape: SliderTickMarkShape.noTickMark),
      child: Slider(
        allowedInteraction: SliderInteraction.tapAndSlide,
        max: widget.pageNumbers.toDouble() - 1,
        value: pageIndex.toDouble(),
        label: pageNumber.toString(),
        divisions: widget.pageNumbers - 1,
        onChanged: (value) {
          setState(() {
            tragetPage = value.round();
          });
        },
        onChangeEnd: (value) {
          widget.pagesController.value = value.round();
          setState(() {
            tragetPage = null;
          });
        },
      ),
    );
  }
}

class MangaSettingsButton extends StatelessWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final Color? color;

  const MangaSettingsButton({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => MangaReaderSettingsDialog(
            contentDetails: contentDetails,
            mediaItems: mediaItems,
          ),
        );
      },
      tooltip: AppLocalizations.of(context)!.settings,
      icon: const Icon(Icons.settings),
      color: color,
    );
  }
}
