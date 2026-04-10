import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/video/video_player_mobile_controls.dart';

class VideoPlayerMobileView extends StatefulWidget {
  const VideoPlayerMobileView({super.key});

  @override
  State<VideoPlayerMobileView> createState() => _VideoPlayerMobileViewState();
}

class _VideoPlayerMobileViewState extends State<VideoPlayerMobileView> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayerMobileControls();
  }
}
