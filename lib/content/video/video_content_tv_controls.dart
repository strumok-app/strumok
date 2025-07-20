import 'dart:async';

import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/track_selector.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/video_source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';

const seekTransitionDuration = Duration(milliseconds: 500);

class AndroidTVControls extends StatefulWidget {
  const AndroidTVControls({super.key, required this.player});

  final Player player;

  @override
  State<AndroidTVControls> createState() => _AndroidTVControlsState();
}

class _AndroidTVControlsState extends State<AndroidTVControls> {
  late bool uiShown = false;
  late bool visible = false;

  FocusNode playPauseFocusNode = FocusNode();

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
  void dispose() {
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
    VideoContentView.currentState.subtitlePaddings.value = EdgeInsets.only(
      bottom: 96,
    );
  }

  void onExit() {
    setState(() {
      visible = false;
    });
    VideoContentView.currentState.subtitlePaddings.value = EdgeInsets.zero;
  }

  void seek(int sec) {
    var playerState = widget.player.state;
    int targetPosition = seekVisible
        ? seekPosition
        : playerState.position.inSeconds;
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
        },
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, result) {
          if (didPop) {
            return;
          }

          if (uiShown) {
            onExit();
            return;
          }

          Navigator.pop(context);
        },
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(navigationMode: NavigationMode.directional),
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
                              const _AndroidTVTopBar(),
                              const Spacer(),
                              // bottom bar
                              const _AndroidTVSeekBar(),
                              _AndroidTVBottomBar(
                                playPauseFocusNode: playPauseFocusNode,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned.fill(child: _AndroidTVVideoBufferingIndicator()),
                Positioned.fill(child: _renderSeekPosition()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderSeekPosition() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 96),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
          ),
        ],
      ),
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

class _AndroidTVTopBar extends StatelessWidget {
  const _AndroidTVTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.2, 1.0],
          colors: [Colors.black45, Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const MediaTitle(),
          const Spacer(),
          const PlayerErrorPopup(),
          const PlayerPlaylistButton(),
        ],
      ),
    );
  }
}

class _AndroidTVVideoBufferingIndicator extends StatefulWidget {
  @override
  State<_AndroidTVVideoBufferingIndicator> createState() =>
      _AndroidTVVideoBufferingIndicatorState();
}

class _AndroidTVVideoBufferingIndicatorState
    extends State<_AndroidTVVideoBufferingIndicator> {
  late bool buffering = controller(context).player.state.buffering;

  StreamSubscription? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription = controller(context).player.stream.buffering.listen((event) {
      setState(() {
        buffering = event;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: buffering ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 150),
        builder: (context, value, child) {
          // Only mount the buffering indicator if the opacity is greater than 0.0.
          // This has been done to prevent redundant resource usage in [CircularProgressIndicator].
          if (value > 0.0) {
            return Opacity(opacity: value, child: child!);
          }
          return const SizedBox.shrink();
        },
        child: const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _AndroidTVBottomBar extends ConsumerWidget {
  final FocusNode playPauseFocusNode;
  const _AndroidTVBottomBar({required this.playPauseFocusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentDetails = VideoContentView.currentContentDetails;
    final mediaItems = VideoContentView.currentMediaItems;

    final currentProgress = ref.watch(collectionItemProvider(contentDetails));

    final isLastItem =
        currentProgress.valueOrNull?.currentItem != mediaItems.length - 1;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 1.0],
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        children: [
          const MaterialDesktopPositionIndicator(),
          const Spacer(),
          const SkipPrevButton(),
          PlayOrPauseButton(focusNode: !isLastItem ? playPauseFocusNode : null),
          SkipNextButton(focusNode: isLastItem ? playPauseFocusNode : null),
          const Spacer(),
          const TrackSelector(),
          const SourceSelector(),
          const PlayerSettingsButton(),
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

  late double position = controller(
    context,
  ).player.state.position.inSeconds.toDouble();
  late double duration = controller(
    context,
  ).player.state.duration.inSeconds.toDouble();
  late double buffer = controller(
    context,
  ).player.state.buffer.inSeconds.toDouble();
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
      subscriptions.addAll([
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
      ]);
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

            await controller(
              context,
            ).player.seek(Duration(seconds: value.ceil()));

            setState(() {
              slidePosition = null;
            });
          });
        },
      ),
    );
  }
}
