import 'package:strumok/content/video/video_content_view.dart';
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
  final PlayerController playerController;

  const VideoContentMobileView({
    super.key,
    required this.player,
    required this.videoController,
    required this.playerController,
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
    final themeData = _createThemeData();
    return MaterialVideoControlsTheme(
      normal: themeData,
      fullscreen: themeData,
      child: Video(
        key: videoStateKey,
        pauseUponEnteringBackgroundMode: false,
        controller: widget.videoController,
        controls: (state) => MaterialVideoControls(state),
      ),
    );
  }

  MaterialVideoControlsThemeData _createThemeData() {
    return MaterialVideoControlsThemeData(
      buttonBarButtonColor: Colors.white,
      topButtonBar: [
        const ExitButton(),
        const SizedBox(width: 8),
        MediaTitle(
          playlistSize: widget.playerController.mediaItems.length,
          contentDetails: widget.playerController.contentDetails,
        ),
        const Spacer(),
        PlayerErrorPopup(playerController: widget.playerController),
        if (widget.playerController.mediaItems.length > 1)
          PlayerPlaylistButton(
            playerController: widget.playerController,
            contentDetails: widget.playerController.contentDetails,
          )
      ],
      primaryButtonBar: [
        const Spacer(flex: 2),
        SkipPrevButton(
          playerController: widget.playerController,
          iconSize: 36.0,
        ),
        const Spacer(),
        const MaterialPlayOrPauseButton(iconSize: 48.0),
        const Spacer(),
        SkipNextButton(
          playerController: widget.playerController,
          iconSize: 36.0,
        ),
        const Spacer(flex: 2),
      ],
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const Spacer(),
        const PlayerSettingsButton(),
        SourceSelector(
          mediaItems: widget.playerController.mediaItems,
          contentDetails: widget.playerController.contentDetails,
        ),
        const MaterialFullscreenButton(),
      ],
      bottomButtonBarMargin: const EdgeInsets.symmetric(horizontal: 16),
      seekGesture: true,
      seekOnDoubleTap: true,
      volumeGesture: true,
      seekBarHeight: 8.0,
    );
  }
}
