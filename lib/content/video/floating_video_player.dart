import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_router.dart';
import 'package:strumok/app_router.gr.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_subtitles.dart';
import 'package:strumok/content/video/video_view.dart';
import 'package:strumok/content/video/widgets.dart';
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
    final showOverlay = controller != null && showFloating;

    if (!showOverlay) {
      return const Positioned.fill(child: SizedBox.shrink());
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
const controlsPadding = 6.0;
const controlsIconSize = 20.0;
const playPauseIconSize = 32.0;

const hPaddingDesktop = 10.0;
const hPaddingMobile = 16.0;

const vPaddingDesktop = 10.0;
const vPaddingMobile = 32.0;

class _FloatingVideoPlayerState extends State<FloatingVideoPlayer> {
  FloatingPlayerCorner currentCorner = FloatingPlayerCorner.bottomRight;
  Offset? dragPosition;
  bool isHovering = false;

  late final bool mobile;
  late final double width;
  late final double videoHeight;
  late final double hPadding;
  late final double vPadding;

  @override
  void initState() {
    super.initState();

    mobile = isMobileDevice();
    width = mobile ? mobilePlayerWidth : desktopPlayerWidth;
    videoHeight = width * 9 / 16;
    vPadding = mobile ? vPaddingMobile : vPaddingDesktop;
    hPadding = mobile ? hPaddingMobile : hPaddingDesktop;

    // Full player controls may have left subtitles shifted up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.subtitlePaddings.value = EdgeInsets.zero;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final minx = hPadding;
    final miny = vPadding;

    final maxx = math.max(minx, screenSize.width - width - hPadding);
    final maxy = math.max(miny, screenSize.height - videoHeight - vPadding);

    Offset getCornerPosition(FloatingPlayerCorner corner) {
      switch (corner) {
        case FloatingPlayerCorner.topLeft:
          return Offset(minx, miny);
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
            currentPosition.dy + videoHeight / 2,
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
        onTap: _openVideoPlayerScreen,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovering = true),
          onExit: (_) => setState(() => isHovering = false),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            color: Colors.black,
            child: VideoContentControllerInheritedWidget(
              controller: widget.controller,
              child: _renderPlayer(),
            ),
          ),
        ),
      ),
    );
  }

  void _openVideoPlayerScreen() {
    final contentDetails = widget.controller.contentDetails;
    widget.appRouter.push(
      VideoContentRoute(
        supplier: contentDetails.supplier,
        id: contentDetails.id,
      ),
    );
  }

  Widget _renderPlayer() {
    // No hover on touch devices, so mobile controls are always visible.
    final showControls = mobile || isHovering;

    return SizedBox(
      width: width,
      height: videoHeight,
      child: Stack(
        children: [
          const VideoView(),
          const Positioned.fill(child: VideoSubtitles()),
          const Positioned.fill(child: BufferingIndicator()),
          if (showControls) ...[
            Positioned(
              top: controlsPadding,
              left: controlsPadding,
              child: PlayOrPauseButton(
                iconSize: playPauseIconSize,
                filled: true,
              ),
            ),
            Positioned(
              top: controlsPadding,
              right: controlsPadding,
              child: FloatingVideoPlayerCloseButton(iconSize: controlsIconSize),
            ),
          ],
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SimpleVideoProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class FloatingVideoPlayerCloseButton extends ConsumerWidget {
  final double? iconSize;

  const FloatingVideoPlayerCloseButton({super.key, this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.filled(
      style: videoFilledIconButtonStyle,
      visualDensity: VisualDensity.comfortable,
      icon: Icon(Icons.close, color: Colors.white, size: iconSize),
      onPressed: () {
        ref.read(videoPlayerProvider.notifier).dispose();
      },
    );
  }
}
