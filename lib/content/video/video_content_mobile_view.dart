import 'package:flutter/services.dart';
import 'package:strumok/content/video/video_content_mobile_controls.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:strumok/utils/visual.dart';

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    super.dispose();
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
