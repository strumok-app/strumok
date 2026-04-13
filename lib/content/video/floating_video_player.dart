import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/app_router.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/utils/tv.dart';

class FloatingVideoPlayerOverlay extends ConsumerStatefulWidget {
  const FloatingVideoPlayerOverlay(this.appRouter, {super.key});

  final AppRouter appRouter;

  @override
  ConsumerState<FloatingVideoPlayerOverlay> createState() =>
      _FloatingVideoPlayerOverlayState();
}

class _FloatingVideoPlayerOverlayState
    extends ConsumerState<FloatingVideoPlayerOverlay> {
  Offset? position;
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(videoPlayerProvider);
    final showFloating = ref.watch(floatingVideoPlayerProvider);

    final showOverlay =
        controllerAsync.value != null && showFloating && !TVDetector.isTV;

    if (!showOverlay) {
      return SizedBox.shrink();
    }

    const width = 320.0;
    const height = 180.0; // 16:9 approx
    final screenSize = MediaQuery.of(context).size;
    final maxx = screenSize.width - width - 10;
    final maxy = screenSize.height - height - 10;

    if (position == null) {
      position = Offset(maxx, maxy);
    } else {
      position = Offset(
        position!.dx.clamp(10, maxx),
        position!.dy.clamp(10, maxy),
      );
    }

    final controller = controllerAsync.value!;

    return Positioned(
      top: position!.dy,
      left: position!.dx,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = position! + details.delta;
          });
        },
        onTap: () {
          controller.playOrPause();
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            color: Colors.black,
            child: SizedBox(
              width: width,
              height: height,
              child: VideoContentControllerInheritedWidget(
                controller: controller,
                child: Stack(
                  children: [
                    const VideoView(),
                    // if (isHovering || Platform.isAndroid || Platform.isIOS)
                    Positioned.fill(
                      child: FloatingVideoPlayerControls(widget.appRouter),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingVideoPlayerControls extends ConsumerWidget {
  const FloatingVideoPlayerControls(this.appRouter, {super.key});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = videoContentController(context);

    return Stack(
      children: [
        Center(
          child: StreamBuilder(
            stream: controller.videoBackendStateStream,
            initialData: controller.videoBackendState,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data?.isPlaying ?? false;

              if (!isPlaying) {
                return Icon(Icons.play_arrow, color: Colors.white, size: 48);
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            onPressed: () {
              final supplier = controller.contentDetails.supplier;
              final id = controller.contentDetails.id;
              appRouter.push(VideoContentRoute(supplier: supplier, id: id));
            },
            icon: const Icon(Symbols.pip_exit, color: Colors.white, size: 24),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () {
              ref.read(videoPlayerProvider.notifier).dispose();
            },
          ),
        ),
      ],
    );
  }
}
