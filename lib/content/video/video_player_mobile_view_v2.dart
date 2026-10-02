import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strumok/content/video/video_player_mobile_controls_v2.dart';

class VideoPlayerMobileViewV2 extends StatefulWidget {
  const VideoPlayerMobileViewV2({super.key});

  @override
  State<VideoPlayerMobileViewV2> createState() =>
      _VideoPlayerMobileViewV2State();
}

class _VideoPlayerMobileViewV2State extends State<VideoPlayerMobileViewV2> {
  static const _landscape = [
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ];
  static const _all = [
    ..._landscape,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(_landscape);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(_all);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const VideoPlayerMobileControlsV2();
  }
}
