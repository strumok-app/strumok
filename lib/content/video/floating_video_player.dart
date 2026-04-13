import 'dart:io';
import 'dart:math' as math;
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

enum FloatingPlayerCorner { topLeft, topRight, bottomLeft, bottomRight }

class _FloatingVideoPlayerOverlayState
    extends ConsumerState<FloatingVideoPlayerOverlay> {
  FloatingPlayerCorner currentCorner = FloatingPlayerCorner.bottomRight;
  Offset? dragPosition;
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(videoPlayerProvider);
    final showFloating = ref.watch(floatingVideoPlayerProvider);

    final showOverlay =
        controllerAsync.value != null && showFloating && !TVDetector.isTV;

    if (!showOverlay) {
      return const SizedBox.shrink();
    }

    const width = 320.0;
    const height = 180.0; // 16:9 approx
    final screenSize = MediaQuery.of(context).size;
    const minx = 10.0;
    const miny = 10.0;
    final maxx = math.max(minx, screenSize.width - width - minx);
    final maxy = math.max(miny, screenSize.height - height - miny);

    Offset getCornerPosition(FloatingPlayerCorner corner) {
      switch (corner) {
        case FloatingPlayerCorner.topLeft:
          return const Offset(minx, miny);
        case FloatingPlayerCorner.topRight:
          return Offset(maxx, miny);
        case FloatingPlayerCorner.bottomLeft:
          return Offset(minx, maxy);
        case FloatingPlayerCorner.bottomRight:
          return Offset(maxx, maxy);
      }
    }

    final currentPosition = dragPosition != null
        ? Offset(
            dragPosition!.dx.clamp(minx, maxx),
            dragPosition!.dy.clamp(miny, maxy),
          )
        : getCornerPosition(currentCorner);

    final controller = controllerAsync.value!;

    return AnimatedPositioned(
      duration: dragPosition != null
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      top: currentPosition.dy,
      left: currentPosition.dx,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            dragPosition = getCornerPosition(currentCorner);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            dragPosition = dragPosition! + details.delta;
          });
        },
        onPanEnd: (details) {
          final center = Offset(
            currentPosition.dx + width / 2,
            currentPosition.dy + height / 2,
          );
          final screenCenter = Offset(
            screenSize.width / 2,
            screenSize.height / 2,
          );

          FloatingPlayerCorner newCorner;
          if (center.dx < screenCenter.dx) {
            newCorner = center.dy < screenCenter.dy
                ? FloatingPlayerCorner.topLeft
                : FloatingPlayerCorner.bottomLeft;
          } else {
            newCorner = center.dy < screenCenter.dy
                ? FloatingPlayerCorner.topRight
                : FloatingPlayerCorner.bottomRight;
          }

          setState(() {
            currentCorner = newCorner;
            dragPosition = null;
          });
        },
        onPanCancel: () {
          setState(() {
            dragPosition = null;
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
                    if (isHovering || Platform.isAndroid || Platform.isIOS)
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
