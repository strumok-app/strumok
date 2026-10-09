import 'package:flutter/material.dart';
import 'package:strumok/content/video/video_player_mobile_controls_v2.dart';

// Orientation and system UI are managed by VideoContentScreen route lifecycle.
class VideoPlayerMobileViewV2 extends StatelessWidget {
  const VideoPlayerMobileViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoPlayerMobileControlsV2();
  }
}
