import 'package:strumok/content/video/video_content_tv_controls.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoContentTVView extends StatelessWidget {
  final Player player;
  final VideoController videoController;

  const VideoContentTVView({
    super.key,
    required this.player,
    required this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: videoController,
      controls: (state) =>
          VideoPlayerControlsWrapper(child: _renderControls(context, state)),
    );
  }

  Widget _renderControls(BuildContext context, VideoState state) {
    return AndroidTVControls(player: player);
  }
}
