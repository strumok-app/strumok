import 'dart:async';

import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/fullscreen.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/media_items_list.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_provider.dart';

class ExitButton extends StatelessWidget {
  final ContentDetails contentDetails;

  const ExitButton({super.key, required this.contentDetails});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: Colors.white,
      onPressed: () async {
        if (isFullscreen(context)) {
          await exitFullscreen(context);
        }

        if (context.mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(
                "/content/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}");
          }
        }
      },
    );
  }
}

// Playlist and source selection

class PlayerPlaylistButton extends ConsumerWidget {
  final PlayerController playerController;
  final ContentDetails contentDetails;

  const PlayerPlaylistButton({
    super.key,
    required this.playerController,
    required this.contentDetails,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final collectionItem =
        ref.watch(collectionItemProvider(contentDetails)).valueOrNull;

    if (collectionItem == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        Navigator.of(context).push(MediaItemsListRoute(
          title: AppLocalizations.of(context)!.episodesList,
          mediaItems: playerController.mediaItems,
          contentProgress: collectionItem,
          onSelect: (item) => playerController.selectItem(item.number),
        ));
      },
      icon: const Icon(Icons.list),
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

// Prev and Next navigation buttons

class SkipPrevButton extends ConsumerWidget {
  final PlayerController playerController;
  final double? iconSize;

  const SkipPrevButton({
    super.key,
    required this.playerController,
    this.iconSize,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentItem = ref
        .watch(
            collectionItemCurrentItemProvider(playerController.contentDetails))
        .valueOrNull;

    final shuffleMode = ref.watch(shuffleModeSettingsProvider);

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    final enabled = currentItem > 0 && !shuffleMode;

    return IconButton(
      onPressed: enabled ? () => playerController.prevItem() : null,
      icon: const Icon(Icons.skip_previous),
      iconSize: iconSize,
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
    );
  }
}

class SkipNextButton extends ConsumerWidget {
  final PlayerController playerController;
  final double? iconSize;
  final FocusNode? focusNode;

  const SkipNextButton({
    super.key,
    required this.playerController,
    this.iconSize,
    this.focusNode,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentItem = ref
        .watch(
            collectionItemCurrentItemProvider(playerController.contentDetails))
        .valueOrNull;

    final shuffleMode = ref.watch(shuffleModeSettingsProvider);

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    final enabled =
        currentItem < playerController.mediaItems.length - 1 || shuffleMode;

    return IconButton(
      onPressed: enabled ? () => playerController.nextItem() : null,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.skip_next),
      iconSize: iconSize,
      color: Colors.white,
      focusColor: Colors.white.withOpacity(0.4),
      disabledColor: Colors.white.withOpacity(0.7),
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
  late final animation = AnimationController(
    vsync: this,
    value: controller(context).player.state.playing ? 1 : 0,
    duration: const Duration(milliseconds: 200),
  );

  StreamSubscription<bool>? subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription ??= controller(context).player.stream.playing.listen((event) {
      if (event) {
        animation.forward();
      } else {
        animation.reverse();
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
      focusColor: Colors.white.withOpacity(0.4),
      onPressed: controller(context).player.playOrPause,
      icon: AnimatedIcon(
        progress: animation,
        color: Colors.white,
        icon: AnimatedIcons.play_pause,
        size: widget.iconSize,
      ),
    );
  }
}
