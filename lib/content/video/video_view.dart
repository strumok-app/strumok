import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatelessWidget {
  const VideoView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = videoContentController(context);
    return ValueListenableBuilder(
      valueListenable: controller.playerController,
      builder: (context, asyncValue, _) {
        return Center(
          child: switch (asyncValue) {
            AsyncLoading() => const CircularProgressIndicator(
              color: Colors.white,
            ),
            AsyncError(:final error) => Text(
              'Error: $error',
              style: const TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            AsyncValue(value: final videoController) => AspectRatio(
              aspectRatio: videoController!.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
          },
        );
      },
    );
  }
}
