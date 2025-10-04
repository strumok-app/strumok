import 'dart:io';

import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/content/video/video_content_desktop_view.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/content/video/video_content_mobile_view.dart';
import 'package:strumok/content/video/video_content_tv_controls.dart';
import 'package:strumok/content/video/video_subtitles.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/utils/tv.dart';

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
  late final ProviderSubscription<AsyncValue<MediaCollectionItem>>
  _collectionItemSubscription;

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

    _collectionItemSubscription = ref.listenManual(collectionItemProv, (
      previous,
      next,
    ) {
      next.whenData((collectionItem) {
        _controller.update(collectionItem);
      });
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _collectionItemSubscription.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return VideoContentControllerInheritedWidget(
      controller: _controller,
      child: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Stack(
          children: [
            VideoView(),
            VideoSubtitles(),
            Positioned.fill(child: _buildControlsView()),
          ],
        ),
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
