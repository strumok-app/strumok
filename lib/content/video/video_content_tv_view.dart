import 'dart:async';

import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/video_source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';

class VideoContentTVView extends StatelessWidget {
  final Player player;
  final VideoController videoController;
  final PlayerController playerController;

  const VideoContentTVView({
    super.key,
    required this.player,
    required this.videoController,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: videoController,
      controls: (state) => _renderControls(context, state),
      subtitleViewConfiguration: subtitleViewConfiguration,
    );
  }

  Widget _renderControls(BuildContext context, VideoState state) {
    return AndroidTVControls(
      player: player,
      playerController: playerController,
    );
  }
}

const seekTransitionDuration = Duration(milliseconds: 500);

class AndroidTVControls extends StatefulWidget {
  const AndroidTVControls({
    super.key,
    required this.player,
    required this.playerController,
  });

  final Player player;
  final PlayerController playerController;

  @override
  State<AndroidTVControls> createState() => _AndroidTVControlsState();
}

class _AndroidTVControlsState extends State<AndroidTVControls> {
  late bool uiShown = false;
  late bool visible = false;

  late bool buffering = controller(context).player.state.buffering;

  FocusNode playPauseFocusNode = FocusNode();
  final List<StreamSubscription> subscriptions = [];

  bool seekVisible = false;
  int seekPosition = 0;
  Timer? _seekTimer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.add(
        controller(context).player.stream.buffering.listen(
          (event) {
            setState(() {
              buffering = event;
            });
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    _seekTimer?.cancel();
    playPauseFocusNode.dispose();
    super.dispose();
  }

  void onEnter() {
    setState(() {
      uiShown = true;
      visible = true;
    });
    playPauseFocusNode.requestFocus();
  }

  void onExit() {
    setState(() {
      visible = false;
    });
  }

  void seek(int sec) {
    var playerState = widget.player.state;
    int targetPosition = seekVisible ? seekPosition : playerState.position.inSeconds;
    targetPosition += sec;

    if (targetPosition < 0) {
      targetPosition = 0;
    } else if (targetPosition > playerState.duration.inSeconds) {
      targetPosition = playerState.duration.inSeconds;
    }

    setState(() {
      seekVisible = true;
      seekPosition = targetPosition;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(seekTransitionDuration, () {
      setState(() {
        seekVisible = false;
      });
      widget.player.safeSeek(Duration(seconds: seekPosition));
    });
  }

  void onBack() {
    if (uiShown) {
      onExit();
    }
  }

  void onPlayPause() {
    widget.player.playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        if (!uiShown) ...{
          const SingleActivator(LogicalKeyboardKey.arrowDown): onEnter,
          const SingleActivator(LogicalKeyboardKey.arrowUp): onEnter,
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => seek(-10),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => seek(10),
          const SingleActivator(LogicalKeyboardKey.select): onPlayPause,
          const SingleActivator(LogicalKeyboardKey.enter): onPlayPause,
        } else ...{
          const SingleActivator(LogicalKeyboardKey.escape): onExit,
        }
      },
      child: BackButtonListener(
        onBackButtonPressed: () async {
          if (uiShown) {
            onExit();
            return true;
          }
          return false;
        },
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(navigationMode: NavigationMode.directional),
          child: Focus(
            autofocus: true,
            child: Stack(
              children: [
                AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  onEnd: () {
                    if (!visible) {
                      setState(() {
                        uiShown = false;
                      });
                    }
                  },
                  child: uiShown
                      ? FocusScope(
                          child: Column(
                            children: [
                              // top bar
                              _renderTopBar(),
                              const Spacer(),
                              // bottom bar
                              const _AndroidTVSeekBar(),
                              _AndroidTVBottomBar(
                                contentDetails: widget.playerController.contentDetails,
                                playerController: widget.playerController,
                                playPauseFocusNode: playPauseFocusNode,
                              )
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned.fill(child: _renderBufferedIndicator()),
                Positioned.fill(child: _renderSeekPosition()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderBufferedIndicator() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: buffering ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child) {
          // Only mount the buffering indicator if the opacity is greater than 0.0.
          // This has been done to prevent redundant resource usage in [CircularProgressIndicator].
          if (value > 0.0) {
            return Opacity(
              opacity: value,
              child: child!,
            );
          }
          return const SizedBox.shrink();
        },
        child: const CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _renderTopBar() {
    final playerController = widget.playerController;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0.2,
            1.0,
          ],
          colors: [
            Colors.black45,
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          MediaTitle(
            contentDetails: playerController.contentDetails,
            playlistSize: playerController.mediaItems.length,
          ),
          const Spacer(),
          PlayerErrorPopup(playerController: playerController),
          if (widget.playerController.mediaItems.length > 1)
            PlayerPlaylistButton(
              playerController: playerController,
              contentDetails: playerController.contentDetails,
            )
        ],
      ),
    );
  }

  _renderSeekPosition() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 96),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        AnimatedOpacity(
          opacity: seekVisible ? 1.0 : 0,
          duration: const Duration(milliseconds: 200),
          child: _renderSeekText(Duration(seconds: seekPosition).label()),
          onEnd: () {
            if (!seekVisible) {
              setState(() {
                seekPosition = 0;
              });
            }
          },
        )
      ]),
    );
  }

  Text _renderSeekText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 32,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 5.0, // shadow blur
            color: Colors.black87,
          ),
        ],
        inherit: true,
      ),
    );
  }
}

class _AndroidTVBottomBar extends ConsumerWidget {
  const _AndroidTVBottomBar({
    required this.contentDetails,
    required this.playerController,
    required this.playPauseFocusNode,
  });

  final ContentDetails contentDetails;
  final PlayerController playerController;
  final FocusNode playPauseFocusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProgress = ref.watch(collectionItemProvider(contentDetails));

    final isLastItem = currentProgress.valueOrNull?.currentItem != playerController.mediaItems.length - 1;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0,
            1.0,
          ],
          colors: [
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        children: [
          const MaterialDesktopPositionIndicator(),
          const Spacer(),
          SkipPrevButton(playerController: playerController),
          PlayOrPauseButton(
            focusNode: !isLastItem ? playPauseFocusNode : null,
          ),
          SkipNextButton(
            playerController: playerController,
            focusNode: isLastItem ? playPauseFocusNode : null,
          ),
          const Spacer(),
          const PlayerSettingsButton(),
          SourceSelector(
            mediaItems: playerController.mediaItems,
            contentDetails: contentDetails,
          ),
        ],
      ),
    );
  }
}

class _AndroidTVSeekBar extends StatefulWidget {
  const _AndroidTVSeekBar();

  @override
  _AndroidTVSeekBarState createState() => _AndroidTVSeekBarState();
}

class _AndroidTVSeekBarState extends State<_AndroidTVSeekBar> {
  static const _seekUnit = 10;

  late double position = controller(context).player.state.position.inSeconds.toDouble();
  late double duration = controller(context).player.state.duration.inSeconds.toDouble();
  late double buffer = controller(context).player.state.buffer.inSeconds.toDouble();
  late int? divisions = _calcDivisions();

  double? slidePosition;
  Timer? timer;

  final List<StreamSubscription> subscriptions = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void listener() {
    setState(() {
      position = controller(context).player.state.position.inSeconds.toDouble();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.position.listen((event) {
            setState(() {
              position = event.inSeconds.toDouble();
            });
          }),
          controller(context).player.stream.duration.listen((event) {
            setState(() {
              duration = event.inSeconds.toDouble();
              divisions = _calcDivisions();
            });
          }),
          controller(context).player.stream.buffer.listen((event) {
            setState(() {
              buffer = event.inSeconds.toDouble();
            });
          }),
        ],
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  int? _calcDivisions() => duration == 0 ? null : (duration / _seekUnit).ceil();

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(tickMarkShape: SliderTickMarkShape.noTickMark),
      child: Slider(
        allowedInteraction: SliderInteraction.slideOnly,
        secondaryTrackValue: buffer,
        value: slidePosition ?? position,
        max: duration,
        divisions: divisions,
        onChanged: (value) {
          timer?.cancel();
          timer = null;
          setState(() {
            slidePosition = value;
          });
        },
        onChangeEnd: (value) {
          timer?.cancel();
          timer = Timer(const Duration(milliseconds: 500), () async {
            timer?.cancel();
            timer = null;

            await controller(context).player.seek(Duration(seconds: value.ceil()));

            setState(() {
              slidePosition = null;
            });
          });
        },
      ),
    );
  }
}
