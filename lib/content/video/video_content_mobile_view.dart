import 'package:strumok/content/video/video_content_mobile_controls.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoContentMobileView extends StatefulWidget {
  final Player player;
  final VideoController videoController;

  const VideoContentMobileView({
    super.key,
    required this.player,
    required this.videoController,
  });

  @override
  State<VideoContentMobileView> createState() => _VideoContentMobileViewState();
}

class _VideoContentMobileViewState extends State<VideoContentMobileView> {
  late final GlobalKey<VideoState> videoStateKey = GlobalKey<VideoState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoStateKey.currentState?.enterFullscreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      key: videoStateKey,
      pauseUponEnteringBackgroundMode: false,
      controller: widget.videoController,
      controls: (state) =>
          VideoPlayerControlsWrapper(child: MobileVideoControls()),
    );
  }
}
