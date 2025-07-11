import 'package:strumok/content/video/track_selector.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/video_source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoContentMobileView extends StatefulWidget {
  final Player player;
  final VideoController videoController;

  const VideoContentMobileView({
    super.key,
    required this.player,
    required this.videoController,
  });

  @override
  State<VideoContentMobileView> createState() => _VideoContentMobileViewState();
}

class _VideoContentMobileViewState extends State<VideoContentMobileView> {
  late final GlobalKey<VideoState> videoStateKey = GlobalKey<VideoState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoStateKey.currentState?.enterFullscreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _createThemeData(Theme.of(context));
    return MaterialVideoControlsTheme(
      normal: themeData,
      fullscreen: themeData,
      child: Video(
        key: videoStateKey,
        pauseUponEnteringBackgroundMode: false,
        controller: widget.videoController,
        controls: (state) =>
            VideoPlayerControlsWrapper(child: MaterialVideoControls(state)),
      ),
    );
  }

  MaterialVideoControlsThemeData _createThemeData(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return MaterialVideoControlsThemeData(
      topButtonBarMargin: const EdgeInsets.only(
        left: 20,
        right: 8,
        bottom: 8,
        top: 8,
      ),
      bottomButtonBarMargin: const EdgeInsets.all(8),
      seekBarThumbColor: colorScheme.primary,
      seekBarPositionColor: colorScheme.primary,
      buttonBarButtonColor: Colors.white,
      topButtonBar: [
        const MediaTitle(),
        const Spacer(),
        const PlayerErrorPopup(),
        const PlayerPlaylistButton(),
      ],
      primaryButtonBar: [
        const Spacer(flex: 2),
        const SkipPrevButton(iconSize: 36.0),
        const Spacer(),
        const MaterialPlayOrPauseButton(iconSize: 48.0),
        const Spacer(),
        const SkipNextButton(iconSize: 36.0),
        const Spacer(flex: 2),
      ],
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        const TrackSelector(),
        const SourceSelector(),
        const PlayerSettingsButton(),
        const MaterialFullscreenButton(),
      ],
      seekGesture: true,
      seekOnDoubleTap: true,
      volumeGesture: true,
      seekBarHeight: 8.0,
    );
  }
}
