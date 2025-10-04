import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/video/video_content_mobile_controls.dart';

class VideoContentMobileView extends StatefulWidget {
  const VideoContentMobileView({super.key});

  @override
  State<VideoContentMobileView> createState() => _VideoContentMobileViewState();
}

class _VideoContentMobileViewState extends State<VideoContentMobileView> {
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
    return VideoContentMobileControls();
  }
}
