import 'dart:io';

import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_desktop_view.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/video/video_player_mobile_view_v2.dart';
import 'package:strumok/content/video/video_player_pip.dart';
import 'package:strumok/content/video/video_player_tv_controls.dart';
import 'package:strumok/content/video/video_subtitles.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/content/video/pip/pip.dart';
import 'package:strumok/utils/tv.dart';

class VideoPlayerView extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return VideoContentControllerInheritedWidget(
      controller: controller,

      child: Stack(
        children: [
          const VideoView(),
          const Positioned.fill(child: VideoSubtitles()),
          ValueListenableBuilder(
            valueListenable: Pip.instance.isActive,
            builder: (context, pipActive, _) => pipActive
                ? Positioned.fill(child: _buildPipView())
                : Positioned.fill(child: _buildControlsView()),
          ),
        ],
      ),
    );
  }

  Widget _buildPipView() {
    return VideoPipBinding(
      controller: controller,
      child: PipVideoControls(interactive: !Platform.isAndroid),
    );
  }

  Widget _buildControlsView() {
    if (TVDetector.isTV) {
      return VideoPlayerTVControls();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return const VideoPlayerMobileViewV2();
    }

    return const VideoPlayerDesktopView();
  }
}
