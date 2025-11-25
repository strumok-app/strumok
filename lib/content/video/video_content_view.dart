import 'dart:async';
import 'dart:io';

import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/content/video/video_content_desktop_view.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content/video/video_content_mobile_view.dart';
import 'package:strumok/content/video/video_content_tv_controls.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_subtitles.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/video_backend/video_backend.dart';

class VideoContentView extends ConsumerStatefulWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const VideoContentView({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  ConsumerState<VideoContentView> createState() => VideoContentViewState();
}

class VideoContentViewState extends ConsumerState<VideoContentView> {
  late final VideoContentController _controller;
  late final List<ProviderSubscription> _providerSubscriptions = [];
  late final StreamSubscription<VideoBackendState>? _playerStreamSubscription;

  @override
  void initState() {
    super.initState();

    final collectionItemProv = collectionItemProvider(widget.contentDetails);

    _controller = VideoContentController(
      contentDetails: widget.contentDetails,
      mediaItems: widget.mediaItems,
      changeCollectionCurentItem: (itemIdx) =>
          ref.read(collectionItemProv.notifier).setCurrentItem(itemIdx),
    );

    final collectionItemSub = ref.listenManual(collectionItemProv, (
      previous,
      next,
    ) {
      next.whenData((collectionItem) {
        _controller.update(collectionItem);
      });
    }, fireImmediately: true);

    _providerSubscriptions.add(collectionItemSub);

    final eqailizerSub = ref.listenManual(equalizerBandsSettingsProvider, (
      previous,
      next,
    ) {
      _controller.setEquilizer(next);
    });

    _providerSubscriptions.add(eqailizerSub);

    _playerStreamSubscription = _controller.videoBackendStateStream.listen((
      playerValue,
    ) {
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

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoContentControllerInheritedWidget(
      controller: _controller,
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
      return VideoContentTVControls();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return VideoContentMobileView();
    }

    return VideoContentDesktopView();
  }
}
