import 'package:strumok/content/video/video_content_desktop_controls.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

class VideoContentDesktopView extends StatefulWidget {
  final Player player;
  final VideoController videoController;

  const VideoContentDesktopView({
    super.key,
    required this.player,
    required this.videoController,
  });

  @override
  State<VideoContentDesktopView> createState() =>
      _VideoContentDesktopViewState();
}

class _VideoContentDesktopViewState extends State<VideoContentDesktopView> {
  bool pipMode = false;

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: widget.videoController,
      controls: (state) => VideoPlayerControlsWrapper(
        child: pipMode
            ? PipVideoControls(state, onPipExit: _switchToPipMode)
            : DesktopVideoControls(onPipEnter: _switchToPipMode),
      ),
    );
  }

  void _switchToPipMode() async {
    setState(() {
      pipMode = !pipMode;
    });

    if (!pipMode) {
      // Exit PiP Mode
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setSize(const Size(1280, 720));
      await windowManager.setAlwaysOnTop(false);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setAlignment(Alignment.center);
    } else {
      // Enter PiP Mode
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setSize(const Size(576, 324));
      await windowManager.setAlwaysOnTop(true);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setAlignment(Alignment.bottomRight);

      VideoContentView.currentState.subtitlePaddings.value = EdgeInsets.zero;
    }
  }
}

class PipVideoControls extends StatefulWidget {
  final VideoState state;
  final VoidCallback onPipExit;
  const PipVideoControls(this.state, {super.key, required this.onPipExit});

  @override
  State<PipVideoControls> createState() => _PipVideoControlsState();
}

class _PipVideoControlsState extends State<PipVideoControls> {
  bool uiVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: MouseRegion(
        onEnter: (_) => _onEnter(),
        onExit: (_) => _onExit(),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.transparent,
                );
              },
            ),
            if (uiVisible) ...[
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialDesktopCustomButton(
                      onPressed: widget.onPipExit,
                      icon: const Icon(Symbols.pip_exit),
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: Center(child: PlayOrPauseButton(iconSize: 48)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onEnter() {
    setState(() {
      uiVisible = true;
    });
  }

  void _onExit() {
    setState(() {
      uiVisible = false;
    });
  }
}
