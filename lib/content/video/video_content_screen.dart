import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/content/details/content_details_provider.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_player_view.dart';
import 'package:strumok/utils/app_orientation.dart';
import 'package:strumok/utils/tv.dart';
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

  final bool _mobileFullscreen = AppOrientation.isMobile;
  bool _inFullscreen = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();

    if (_mobileFullscreen) {
      _inFullscreen = true;
      AppOrientation.enterFullscreenVideo();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      videoPlayerProviderNotifier.load(widget.supplier, widget.id);
      floatingVideoPlayerProviderNotifier.hide();
    });
  }

  Future<void> _leaveFullscreen() async {
    if (!_inFullscreen) {
      return;
    }

    _inFullscreen = false;
    await AppOrientation.exitFullscreenVideo();
  }

  // Rotate back before popping so the previous screen is never shown
  // with landscape layout.
  Future<void> _rotateAndPop() async {
    if (_exiting) {
      return;
    }

    _exiting = true;
    final navigator = Navigator.of(context);
    final view = View.of(context);

    await _leaveFullscreen();
    if (AppOrientation.isPhone) {
      await AppOrientation.waitForPortrait(view);
    }

    if (mounted) {
      navigator.pop();
    }
  }

  @override
  void dispose() {
    _leaveFullscreen();

    if (TVDetector.isTV) {
      videoPlayerProviderNotifier.dispose();
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (AppPreferences.floatingVideoPlayerEnabled) {
          floatingVideoPlayerProviderNotifier.show();
        } else {
          videoPlayerProviderNotifier.dispose();
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayer = ref.watch(videoPlayerProvider);

    final content = Material(
      color: Colors.black,
      child: videoPlayer.when(
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

    if (!_mobileFullscreen) {
      return content;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          // forced pop (Navigator.pop) - restore orientation as early as possible
          _leaveFullscreen();
        } else {
          _rotateAndPop();
        }
      },
      child: content,
    );
  }
}
