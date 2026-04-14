import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/app_router.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';

enum FloatingPlayerCorner { topLeft, topRight, bottomLeft, bottomRight }

class FloatingVideoPlayerOverlay extends ConsumerWidget {
  const FloatingVideoPlayerOverlay(this.appRouter, {super.key});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerAsync = ref.watch(videoPlayerProvider);
    final showFloating = ref.watch(floatingVideoPlayerProvider);

    final controller = controllerAsync.value;
    final showOverlay = controller != null && showFloating && !TVDetector.isTV;

    if (!showOverlay) {
      return const SizedBox.shrink();
    }

    return FloatingVideoPlayer(controller: controller, appRouter: appRouter);
  }
}

class FloatingVideoPlayer extends StatefulWidget {
  const FloatingVideoPlayer({
    super.key,
    required this.controller,
    required this.appRouter,
  });

  final VideoPlayerController controller;
  final AppRouter appRouter;

  @override
  State<FloatingVideoPlayer> createState() => _FloatingVideoPlayerState();
}

const mobilePlayerWidth = 220.0;
const desktopPlayerWidth = 420.0;
const hPadding = 16.0;
const vPadding = 16.0;
const mobileControlsHeight = 24.0;

class _FloatingVideoPlayerState extends State<FloatingVideoPlayer> {
  FloatingPlayerCorner currentCorner = FloatingPlayerCorner.bottomRight;
  Offset? dragPosition;
  bool isHovering = false;

  late final bool mobile;
  late final double width;
  late final double videoHeight;
  late final double totalHeight;

  @override
  void initState() {
    super.initState();

    mobile = isMobileDevice();
    width = mobile ? mobilePlayerWidth : desktopPlayerWidth;
    videoHeight = width * 9 / 16;
    totalHeight = videoHeight + (mobile ? mobileControlsHeight : 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    const minx = hPadding;
    const miny = vPadding;

    final maxx = math.max(minx, screenSize.width - width - hPadding);
    final maxy = math.max(miny, screenSize.height - totalHeight - vPadding);

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
            currentPosition.dy + totalHeight / 2,
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
          widget.controller.playOrPause();
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            color: Colors.black,
            child: VideoContentControllerInheritedWidget(
              controller: widget.controller,
              child: mobile ? _renderMobile() : _renderDesktop(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderMobile() {
    return Column(
      children: [
        SizedBox(
          width: width,
          height: videoHeight,
          child: Stack(
            children: [
              const VideoView(),
              const Positioned.fill(child: BufferingIndicator()),
              Positioned(
                top: 0,
                left: 0,
                child: FloatingPlayerExpandButton(widget.appRouter),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: FloatingVideoPlayerCloseButton(),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SeekBackwardButton(iconSize: 24),
            const SizedBox(width: 16),
            const PlayOrPauseButton(iconSize: 24),
            const SizedBox(width: 16),
            const SeekForwardButton(iconSize: 24),
          ],
        ),
      ],
    );
  }

  Widget _renderDesktop() {
    return SizedBox(
      width: width,
      height: videoHeight,
      child: Stack(
        children: [
          const VideoView(),
          const Positioned.fill(child: BufferingIndicator()),
          if (isHovering) ...[
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SeekBackwardButton(),
                  const SizedBox(width: 16),
                  const PlayOrPauseButton(iconSize: 48),
                  const SizedBox(width: 16),
                  const SeekForwardButton(),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: FloatingPlayerExpandButton(widget.appRouter),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: FloatingVideoPlayerCloseButton(),
            ),
          ],
        ],
      ),
    );
  }
}

class FloatingPlayerExpandButton extends ConsumerWidget {
  const FloatingPlayerExpandButton(this.appRouter, {super.key});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = videoContentController(context);

    return IconButton(
      onPressed: () {
        final supplier = controller.contentDetails.supplier;
        final id = controller.contentDetails.id;
        appRouter.push(VideoContentRoute(supplier: supplier, id: id));
      },
      icon: const Icon(Symbols.pip_exit, color: Colors.white, size: 24),
    );
  }
}

class FloatingVideoPlayerCloseButton extends ConsumerWidget {
  const FloatingVideoPlayerCloseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.white, size: 24),
      onPressed: () {
        ref.read(videoPlayerProvider.notifier).dispose();
      },
    );
  }
}
