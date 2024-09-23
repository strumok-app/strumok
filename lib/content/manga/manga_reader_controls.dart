import 'package:cloud_hook/collection/collection_item_provider.dart';
import 'package:cloud_hook/content/manga/manga_reader_settings_dialog.dart';
import 'package:cloud_hook/content/manga/widgets.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/layouts/app_theme.dart';
import 'package:cloud_hook/utils/android_tv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MangaReaderControlsRoute<T> extends PopupRoute<T> {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueListenable<int> page;
  final int pageNumbers;
  final ValueChanged<int> onPageChanged;

  MangaReaderControlsRoute({
    required this.contentDetails,
    required this.mediaItems,
    required this.page,
    required this.pageNumbers,
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
      child: AppTheme(
        child: SafeArea(
          child: MangaReaderControls(
            contentDetails: contentDetails,
            mediaItems: mediaItems,
            page: page,
            pageNumbers: pageNumbers,
            onPageChanged: onPageChanged,
          ),
        ),
      ),
    );
  }
}

class MangaReaderControls extends StatelessWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueListenable<int> page;
  final int pageNumbers;
  final ValueChanged<int> onPageChanged;

  const MangaReaderControls({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.page,
    required this.pageNumbers,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        context.pop();
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
            page: page,
            pageNumbers: pageNumbers,
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0.1,
            1.0,
          ],
          colors: [
            Colors.black45,
            Colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
          bottom: 8,
          right: 16,
          left: 16,
        ),
        child: Row(children: [
          if (!AndroidTVDetector.isTV) ...[
            BackButton(
              onPressed: () {
                context.go(
                    "/content/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}");
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
        ref
            .read(collectionItemProvider(contentDetails).notifier)
            .setCurrentItem(item.number);
        context.pop();
      },
      autofocus: true,
      color: Colors.white,
    );
  }
}

class MangaReaderControlBottomBar extends StatelessWidget {
  final List<ContentMediaItem> mediaItems;
  final ContentDetails contentDetails;
  final ValueListenable<int> page;
  final int pageNumbers;
  final ValueChanged<int> onPageChanged;

  const MangaReaderControlBottomBar({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.page,
    required this.pageNumbers,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
        valueListenable: page,
        builder: (context, pageIndex, child) {
          final pageNumber = pageIndex + 1;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [
                  0.1,
                  1.0,
                ],
                colors: [
                  Colors.transparent,
                  Colors.black54,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  allowedInteraction: SliderInteraction.slideOnly,
                  max: pageNumbers.toDouble() - 1,
                  value: pageIndex.toDouble(),
                  label: pageNumber.toString(),
                  divisions: pageNumbers - 1,
                  onChanged: (value) {
                    onPageChanged(value.round());
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "$pageNumber / $pageNumbers",
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => MangaReaderSettingsDialog(
                              contentDetails: contentDetails,
                              mediaItems: mediaItems,
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
