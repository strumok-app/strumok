import 'dart:async';

import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/content/video/video_content_desktop_controls.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/video_source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/utils/text.dart';

const seekTransitionDuration = Duration(milliseconds: 500);

class VideoContentTVControls extends StatefulWidget {
  const VideoContentTVControls({super.key});

  @override
  State<VideoContentTVControls> createState() => _VideoContentTVControlsState();
}

class _VideoContentTVControlsState extends State<VideoContentTVControls> {
  late bool _uiShown = false;
  late bool _visible = false;

  final FocusNode _playPauseFocusNode = FocusNode();

  bool _seekVisible = false;
  int _seekPosition = 0;
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
    _playPauseFocusNode.dispose();
    super.dispose();
  }

  void onEnter() {
    setState(() {
      _uiShown = true;
      _visible = true;
    });
    _playPauseFocusNode.requestFocus();
    videoContentController(context).subtitlePaddings.value = EdgeInsets.only(
      bottom: 96,
    );
  }

  void onExit() {
    setState(() {
      _visible = false;
    });
    videoContentController(context).subtitlePaddings.value = EdgeInsets.zero;
  }

  void seek(int sec) {
    var playerState = videoContentController(context).playerState;
    int targetPosition = _seekVisible
        ? _seekPosition
        : playerState.position.inSeconds;
    targetPosition += sec;

    if (targetPosition < 0) {
      targetPosition = 0;
    } else if (targetPosition > playerState.duration.inSeconds) {
      targetPosition = playerState.duration.inSeconds;
    }

    setState(() {
      _seekVisible = true;
      _seekPosition = targetPosition;
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(seekTransitionDuration, () {
      setState(() {
        _seekVisible = false;
      });
      videoContentController(context).seekTo(Duration(seconds: _seekPosition));
    });
  }

  void onBack() {
    if (_uiShown) {
      onExit();
    }
  }

  void onPlayPause() {
    videoContentController(context).playOrPause();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        if (!_uiShown) ...{
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

          if (_uiShown) {
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
                  opacity: _visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  onEnd: () {
                    if (!_visible) {
                      setState(() {
                        _uiShown = false;
                      });
                    }
                  },
                  child: _uiShown
                      ? FocusScope(
                          child: Column(
                            children: [
                              // top bar
                              const _AndroidTVTopBar(),
                              const Spacer(),
                              // bottom bar
                              const _TVSeekBar(),
                              _AndroidTVBottomBar(
                                playPauseFocusNode: _playPauseFocusNode,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned.fill(child: _TVVideoBufferingIndicator()),
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
            opacity: _seekVisible ? 1.0 : 0,
            duration: const Duration(milliseconds: 200),
            child: _renderSeekText(
              formatDuration(Duration(seconds: _seekPosition)),
            ),
            onEnd: () {
              if (!_seekVisible) {
                setState(() {
                  _seekPosition = 0;
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
          const PlayerPlaylistButton(),
        ],
      ),
    );
  }
}

class _TVVideoBufferingIndicator extends StatefulWidget {
  @override
  State<_TVVideoBufferingIndicator> createState() =>
      _TVVideoBufferingIndicatorState();
}

class _TVVideoBufferingIndicatorState
    extends State<_TVVideoBufferingIndicator> {
  late bool _buffering = videoContentController(
    context,
  ).playerState.isBuffering;

  StreamSubscription? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription = videoContentController(context).playerStream.listen((
      event,
    ) {
      if (_buffering != event.isBuffering) {
        setState(() {
          _buffering = event.isBuffering;
        });
      }
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
        tween: Tween<double>(begin: 0.0, end: _buffering ? 1.0 : 0.0),
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
    final controller = videoContentController(context);
    final contentDetails = controller.contentDetails;
    final mediaItems = controller.mediaItems;

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
          const DesktopVideoControlsPositionIndicator(),
          const Spacer(),
          const SkipPrevButton(),
          PlayOrPauseButton(focusNode: !isLastItem ? playPauseFocusNode : null),
          SkipNextButton(focusNode: isLastItem ? playPauseFocusNode : null),
          const Spacer(),
          const SourceSelector(),
          const PlayerSettingsButton(),
        ],
      ),
    );
  }
}

class _TVSeekBar extends StatefulWidget {
  const _TVSeekBar();

  @override
  _TVSeekBarState createState() => _TVSeekBarState();
}

class _TVSeekBarState extends State<_TVSeekBar> {
  static const _seekUnit = 10;

  late Duration position = videoContentController(context).playerState.position;
  late Duration duration = videoContentController(context).playerState.duration;
  late Duration buffer = videoContentController(context).playerState.lastBuffer;
  late int? divisions = _calcDivisions();

  double? slidePosition;
  Timer? timer;

  StreamSubscription? _subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void listener() {
    setState(() {
      position = videoContentController(context).playerState.position;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= videoContentController(context).playerStream.listen((
      event,
    ) {
      if (position != event.position ||
          duration != event.duration ||
          buffer != event.lastBuffer) {
        setState(() {
          if (duration != event.duration) {
            duration = event.duration;
            divisions = _calcDivisions();
          }
          position = event.position;
          buffer = event.lastBuffer;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  int? _calcDivisions() => duration == Duration.zero
      ? null
      : (duration.inSeconds / _seekUnit).ceil();

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(tickMarkShape: SliderTickMarkShape.noTickMark),
      child: Slider(
        allowedInteraction: SliderInteraction.slideOnly,
        secondaryTrackValue: buffer.inSeconds.toDouble(),
        value: slidePosition ?? position.inSeconds.toDouble(),
        max: duration.inSeconds.toDouble(),
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

            videoContentController(
              context,
            ).seekTo(Duration(seconds: value.ceil()));

            setState(() {
              slidePosition = null;
            });
          });
        },
      ),
    );
  }
}
