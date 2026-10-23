import 'package:flutter/material.dart';
import 'package:strumok/content/video/video_player_desktop_controls.dart';

// Window fullscreen and PIP state are managed by VideoContentScreen route lifecycle.
class VideoPlayerDesktopView extends StatelessWidget {
  const VideoPlayerDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoPlayerDesktopControls();
  }
}
