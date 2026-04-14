import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_desktop_controls.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayerDesktopView extends StatefulWidget {
  const VideoPlayerDesktopView({super.key});

  @override
  State<VideoPlayerDesktopView> createState() => _VideoPlayerDesktopViewState();
}

class _VideoPlayerDesktopViewState extends State<VideoPlayerDesktopView> {
  bool pipMode = false;

  @override
  Widget build(BuildContext context) {
    return pipMode
        ? PipVideoControls(onPipExit: _switchToPipMode)
        : VideoPlayerDesktopControls(onPipEnter: _switchToPipMode);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    windowManager.setFullScreen(false);
    super.dispose();
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
      await windowManager.setFullScreen(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setSize(const Size(576, 324));
      await windowManager.setAlwaysOnTop(true);
      await Future.delayed(const Duration(milliseconds: 100));
      await windowManager.setAlignment(Alignment.bottomRight);

      if (mounted) {
        videoContentController(context).subtitlePaddings.value =
            EdgeInsets.zero;
      }
    }
  }
}

class PipVideoControls extends StatefulWidget {
  final VoidCallback onPipExit;
  const PipVideoControls({super.key, required this.onPipExit});

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
            const Positioned.fill(child: BufferingIndicator()),
            if (uiVisible) ...[
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: widget.onPipExit,
                      icon: const Icon(Symbols.pip_exit),
                    ),
                  ),
                ),
              ),
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
