import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_controller.dart';

class VideoView extends StatelessWidget {
  const VideoView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = videoContentController(context);
    return ValueListenableBuilder(
      valueListenable: controller.videoBackend,
      builder: (context, asyncValue, _) {
        return Center(
          child: switch (asyncValue) {
            AsyncLoading() => SizedBox.shrink(),
            AsyncError(:final error) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error: $error',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const RetryButton(),
              ],
            ),
            AsyncValue(value: final videoBackend) => AspectRatio(
              aspectRatio: videoBackend!.value.aspectRatio,
              child: videoBackend.buildVideoWidget(),
            ),
          },
        );
      },
    );
  }
}
