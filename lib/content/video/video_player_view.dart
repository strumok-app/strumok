import 'dart:async';
import 'dart:io';

import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_desktop_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content/video/video_player_mobile_view.dart';
import 'package:strumok/content/video/video_player_tv_controls.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_subtitles.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/video_backend/video_backend.dart';

class VideoPlayerView extends ConsumerStatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerView({super.key, required this.controller});

  @override
  ConsumerState<VideoPlayerView> createState() => VideoContentViewState();
}

class VideoContentViewState extends ConsumerState<VideoPlayerView> {
  late final List<ProviderSubscription> _providerSubscriptions = [];
  late final StreamSubscription<VideoBackendState>? _playerStreamSubscription;

  @override
  void initState() {
    super.initState();

    final collectionItemProv = collectionItemProvider(
      widget.controller.contentDetails,
    );

    final collectionItemSub = ref.listenManual(collectionItemProv, (
      previous,
      next,
    ) {
      next.whenData((collectionItem) {
        widget.controller.update(collectionItem);
      });
    }, fireImmediately: true);

    _providerSubscriptions.add(collectionItemSub);

    final eqailizerSub = ref.listenManual(equalizerBandsSettingsProvider, (
      previous,
      next,
    ) {
      widget.controller.setEquilizer(next);
    });

    _providerSubscriptions.add(eqailizerSub);

    _playerStreamSubscription = widget.controller.videoBackendStateStream
        .listen((playerValue) {
          // Update collection item position when player position changes
          if (playerValue.position > Duration.zero) {
            ref
                .read(collectionItemProv.notifier)
                .setCurrentPosition(
                  playerValue.position.inSeconds,
                  playerValue.duration.inSeconds,
                );
          }
        });
  }

  @override
  void dispose() {
    _playerStreamSubscription?.cancel();

    for (final sub in _providerSubscriptions) {
      sub.close();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoContentControllerInheritedWidget(
      controller: widget.controller,
      child: Stack(
        children: [
          VideoView(),
          Positioned.fill(child: _buildControlsView()),
          VideoSubtitles(),
        ],
      ),
    );
  }

  Widget _buildControlsView() {
    if (TVDetector.isTV) {
      return VideoPlayerTVControls();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return VideoPlayerMobileView();
    }

    return VideoPlayerDesktopView();
  }
}
