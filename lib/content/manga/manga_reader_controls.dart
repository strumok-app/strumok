import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/manga/manga_reader_settings_dialog.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/utils/tv.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/utils/visual.dart';

class MangaReaderControlsRoute<T> extends PopupRoute<T> {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueChanged<int> onPageChanged;

  MangaReaderControlsRoute({
    required this.contentDetails,
    required this.mediaItems,
    required this.onPageChanged,
  });

  @override
  Color? get barrierColor => Colors.transparent;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dissmiss';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

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
          onPageChanged: onPageChanged,
        ),
      ),
    );
  }
}

class MangaReaderControls extends StatelessWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueChanged<int> onPageChanged;

  const MangaReaderControls({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        Navigator.of(context).pop();
      },
      child: Material(
        color: Colors.transparent,
        child: Column(children: [
          MangaReaderControlTopBar(
            contentDetails: contentDetails,
            mediaItems: mediaItems,
          ),
          const Spacer(),
          MangaReaderControlBottomBar(
            contentDetails: contentDetails,
            mediaItems: mediaItems,
            onPageChanged: onPageChanged,
          )
        ]),
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

    return Container(
      color: Colors.black45,
      child: Padding(
        padding: EdgeInsets.only(left: mobile ? 8 : 20, right: 8, bottom: 8, top: 8),
        child: Row(children: [
          if (!TVDetector.isTV) ...[
            BackButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              color: Colors.white,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            contentDetails.title,
            style: theme.textTheme.titleMedium!.copyWith(
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _renderVolumesBotton(context, ref)
        ]),
      ),
    );
  }

  Widget _renderVolumesBotton(BuildContext context, WidgetRef ref) {
    return VolumesButton(
      contentDetails: contentDetails,
      mediaItems: mediaItems,
      onSelect: (item) {
        ref.read(collectionItemProvider(contentDetails).notifier).setCurrentItem(item.number);
        Navigator.of(context).pop();
      },
      autofocus: true,
      color: Colors.white,
    );
  }
}

class MangaReaderControlBottomBar extends ConsumerStatefulWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;
  final ValueChanged<int> onPageChanged;

  const MangaReaderControlBottomBar({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.onPageChanged,
  });

  @override
  ConsumerState<MangaReaderControlBottomBar> createState() => _MangaReaderControlBottomBarState();
}

class _MangaReaderControlBottomBarState extends ConsumerState<MangaReaderControlBottomBar> {
  int? tragetPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final position = ref.watch(collectionItemCurrentMediaItemPositionProvider(widget.contentDetails)).value;

    if (position == null) {
      return const SizedBox.shrink();
    }

    final pageNumbers = position.length;
    final pageIndex = tragetPage ?? position.position;
    final pageNumber = pageIndex + 1;

    final mobile = isMobile(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(navigationMode: NavigationMode.directional),
      child: Container(
        color: Colors.black45,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!mobile)
                Text(
                  "$pageNumber / $pageNumbers",
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                  ),
                ),
              Expanded(
                child: Slider(
                  allowedInteraction: SliderInteraction.tapAndSlide,
                  max: pageNumbers.toDouble() - 1,
                  value: pageIndex.toDouble(),
                  label: pageNumber.toString(),
                  divisions: pageNumbers - 1,
                  onChanged: (value) {
                    setState(() {
                      tragetPage = value.round();
                    });
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      tragetPage = value.round();
                    });
                    widget.onPageChanged(value.round());
                  },
                ),
              ),
              MangaSettingsButton(
                contentDetails: widget.contentDetails,
                mediaItems: widget.mediaItems,
                color: Colors.white,
              ),
            ],
          ),
        ),
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
