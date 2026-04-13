import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/content/details/content_details_provider.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_player_view.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class VideoContentScreen extends ConsumerStatefulWidget {
  const VideoContentScreen({
    super.key,
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  ConsumerState<VideoContentScreen> createState() => _VideoContentScreenState();
}

class _VideoContentScreenState extends ConsumerState<VideoContentScreen> {
  late final videoPlayerProviderNotifier = ref.read(
    videoPlayerProvider.notifier,
  );
  late final floatingVideoPlayerProviderNotifier = ref.read(
    floatingVideoPlayerProvider.notifier,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      videoPlayerProviderNotifier.load(widget.supplier, widget.id);
      floatingVideoPlayerProviderNotifier.hide();
    });
  }

  @override
  void dispose() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (AppPreferences.floatingVideoPlayerEnabled) {
        floatingVideoPlayerProviderNotifier.show();
      } else {
        videoPlayerProviderNotifier.dispose();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayer = ref.watch(videoPlayerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: videoPlayer.when(
        skipLoadingOnRefresh: false,
        data: (controller) {
          if (controller != null) {
            return VideoPlayerView(controller: controller);
          }

          return SizedBox.shrink();
        },
        error: (error, stackTrace) => DisplayError(
          error: error,
          onRefresh: () =>
              ref.refresh(detailsProvider(widget.supplier, widget.id).future),
        ),
        loading: () => const Material(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      ),
    );
  }
}
