import 'package:strumok/content/video/track_selector.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/video_source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final GlobalKey<VideoState> videoStateKey = GlobalKey<VideoState>();

  late final _keyboardShortcuts = {
    const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
        widget.player.play(),
    const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
        widget.player.pause(),
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
        widget.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext):
        VideoContentView.currentState.nextItem,
    const SingleActivator(LogicalKeyboardKey.bracketLeft):
        VideoContentView.currentState.nextItem,
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious):
        VideoContentView.currentState.prevItem,
    const SingleActivator(LogicalKeyboardKey.bracketRight):
        VideoContentView.currentState.prevItem,
    const SingleActivator(LogicalKeyboardKey.space): () =>
        widget.player.playOrPause(),
    const SingleActivator(LogicalKeyboardKey.keyJ): () {
      widget.player.safeSeek(
        widget.player.state.position - const Duration(seconds: 60),
      );
    },
    const SingleActivator(LogicalKeyboardKey.keyI): () {
      widget.player.safeSeek(
        widget.player.state.position + const Duration(seconds: 60),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
      widget.player.safeSeek(
        widget.player.state.position - const Duration(seconds: 10),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () {
      widget.player.safeSeek(
        widget.player.state.position + const Duration(seconds: 10),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowUp): () {
      final volume = widget.player.state.volume + 5.0;
      widget.player.setVolume(volume.clamp(0.0, 100.0));
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () {
      final volume = widget.player.state.volume - 5.0;
      widget.player.setVolume(volume.clamp(0.0, 100.0));
    },
    // dirty hack with video state...
    const SingleActivator(LogicalKeyboardKey.keyF): () =>
        videoStateKey.currentState?.toggleFullscreen(),
    const SingleActivator(LogicalKeyboardKey.enter): () =>
        videoStateKey.currentState?.toggleFullscreen(),
    const SingleActivator(LogicalKeyboardKey.escape): () =>
        videoStateKey.currentState?.exitFullscreen(),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialDesktopVideoControlsTheme(
      normal: _createThemeData(theme, false),
      fullscreen: _createThemeData(theme, true),
      child: Video(
        key: videoStateKey,
        controller: widget.videoController,
        controls: (state) => VideoPlayerControlsWrapper(
          child: pipMode
              ? PipVideoControls(state, onPipExit: _switchToPipMode)
              : MaterialDesktopVideoControls(state),
        ),
      ),
    );
  }

  MaterialDesktopVideoControlsThemeData _createThemeData(
    ThemeData theme,
    bool fullscreen,
  ) {
    final colorScheme = theme.colorScheme;

    return MaterialDesktopVideoControlsThemeData(
      buttonBarButtonColor: Colors.white,
      topButtonBarMargin: const EdgeInsets.all(8),
      bottomButtonBarMargin: const EdgeInsets.all(8),
      topButtonBar: [
        const ExitButton(),
        const SizedBox(width: 8),
        const MediaTitle(),
        const PlayerErrorPopup(),
        const PlayerPlaylistButton(),
      ],
      seekBarThumbColor: colorScheme.primary,
      seekBarPositionColor: colorScheme.primary,
      bottomButtonBar: [
        const SkipPrevButton(),
        const PlayOrPauseButton(),
        const SkipNextButton(),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        if (!fullscreen)
          MaterialCustomButton(
            onPressed: _switchToPipMode,
            icon: const Icon(Symbols.pip),
          ),
        const TrackSelector(),
        const SourceSelector(),
        const PlayerSettingsButton(),
        const MaterialDesktopFullscreenButton(),
      ],
      keyboardShortcuts: _keyboardShortcuts,
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
