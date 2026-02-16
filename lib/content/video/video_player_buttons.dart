import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/media_items_list.dart';
import 'package:strumok/content/video/content_details_video_actions.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: Colors.white,
      onPressed: () async {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

// Playlist and source selection

class PlayerPlaylistButton extends ConsumerWidget {
  const PlayerPlaylistButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = videoContentController(context);
    final contentDetails = controller.contentDetails;
    final mediaItems = controller.mediaItems;

    final collectionItem = ref
        .watch(collectionItemProvider(contentDetails))
        .value;

    if (collectionItem == null || mediaItems.length < 2) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MediaItemsListRoute(
            title: AppLocalizations.of(context)!.episodesList,
            mediaItems: mediaItems,
            contentProgress: collectionItem,
            onSelect: (item) =>
                controller.changeCollectionCurentItem(item.number),
            itemBuilder: playlistItemBuilder(contentDetails),
          ),
        );
      },
      icon: const Icon(Icons.playlist_play),
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.7),
    );
  }
}

// Prev and Next navigation buttons

class SkipPrevButton extends ConsumerWidget {
  final double? iconSize;

  const SkipPrevButton({super.key, this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = videoContentController(context);
    final contentDetails = controller.contentDetails;

    final currentItem = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .value;

    final shuffleMode = ref.watch(shuffleModeSettingsProvider);

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    final enabled = currentItem > 0 && !shuffleMode;

    return IconButton(
      focusNode: enabled ? null : FocusNode(canRequestFocus: false),
      onPressed: enabled ? controller.prevItem : null,
      icon: const Icon(Icons.skip_previous),
      iconSize: iconSize,
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.7),
    );
  }
}

class SkipNextButton extends ConsumerWidget {
  final double? iconSize;
  final FocusNode? focusNode;

  const SkipNextButton({super.key, this.iconSize, this.focusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = videoContentController(context);
    final contentDetails = controller.contentDetails;
    final mediaItems = controller.mediaItems;

    final currentItem = ref
        .watch(collectionItemCurrentItemProvider(contentDetails))
        .value;

    final shuffleMode = ref.watch(shuffleModeSettingsProvider);

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    final enabled = currentItem < mediaItems.length - 1 || shuffleMode;

    return IconButton(
      onPressed: enabled ? controller.nextItem : null,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.skip_next),
      iconSize: iconSize,
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.7),
      focusNode: focusNode,
    );
  }
}

class PlayOrPauseButton extends StatefulWidget {
  final double? iconSize;
  final Color? iconColor;
  final FocusNode? focusNode;

  const PlayOrPauseButton({
    super.key,
    this.iconSize,
    this.iconColor,
    this.focusNode,
  });

  @override
  PlayOrPauseButtonState createState() => PlayOrPauseButtonState();
}

class PlayOrPauseButtonState extends State<PlayOrPauseButton>
    with SingleTickerProviderStateMixin {
  late bool isPlaying = videoContentController(
    context,
  ).videoBackendState.isPlaying;

  late final animation = AnimationController(
    vsync: this,
    value: isPlaying ? 1 : 0,
    duration: const Duration(milliseconds: 200),
  );

  StreamSubscription? subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription ??= videoContentController(context).videoBackendStateStream
        .listen((event) {
          if (isPlaying != event.isPlaying) {
            if (event.isPlaying) {
              animation.forward();
            } else {
              animation.reverse();
            }
            isPlaying = event.isPlaying;
          }
        });
  }

  @override
  void dispose() {
    animation.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      focusNode: widget.focusNode,
      color: Colors.white,
      onPressed: videoContentController(context).playOrPause,
      icon: AnimatedIcon(
        progress: animation,
        color: Colors.white,
        icon: AnimatedIcons.play_pause,
        size: widget.iconSize,
      ),
    );
  }
}
