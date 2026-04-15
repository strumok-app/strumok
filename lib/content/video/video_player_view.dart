import 'dart:io';

import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_desktop_view.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/video/video_player_mobile_view.dart';
import 'package:strumok/content/video/video_player_tv_controls.dart';
import 'package:strumok/content/video/video_subtitles.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/utils/tv.dart';

class VideoPlayerView extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerView({super.key, required this.controller});

  Widget build(BuildContext context) {
    return VideoContentControllerInheritedWidget(
      controller: controller,
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
