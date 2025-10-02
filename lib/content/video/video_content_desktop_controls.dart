import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/video_source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:strumok/utils/text.dart';

/// {@macro material_desktop_video_controls}
class DesktopVideoControls extends StatefulWidget {
  final VoidCallback onPipEnter;
  const DesktopVideoControls({super.key, required this.onPipEnter});

  @override
  State<DesktopVideoControls> createState() => _DesktopVideoControlsState();
}

/// {@macro material_desktop_video_controls}
class _DesktopVideoControlsState extends State<DesktopVideoControls> {
  static final controlsHoverDuration = const Duration(seconds: 3);
  static const subtitleVerticalShiftOffset = 96.0;
  static const buttonBarHeight = 56.0;

  late bool _mount = true;
  late bool _visible = true;

  Timer? _timer;

  late bool _buffering = VideoContentView.currentState.playerState.isBuffering;

  DateTime _last = DateTime.now();

  StreamSubscription? _subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _subscription = VideoContentView.currentState.playerStream.listen((event) {
      if (_buffering != event.isBuffering) {
        setState(() {
          _buffering = event.isBuffering;
        });
      }
    });

    _timer = Timer(controlsHoverDuration, () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
        unshiftSubtitle();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void shiftSubtitle() {
    VideoContentView.currentState.subtitlePaddings.value = EdgeInsets.fromLTRB(
      0.0,
      0.0,
      0.0,
      subtitleVerticalShiftOffset,
    );
  }

  void unshiftSubtitle() {
    VideoContentView.currentState.subtitlePaddings.value = EdgeInsets.zero;
  }

  void onHover() {
    setState(() {
      _mount = true;
      _visible = true;
    });
    shiftSubtitle();
    _timer?.cancel();
    _timer = Timer(controlsHoverDuration, () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
        unshiftSubtitle();
      }
    });
  }

  void onEnter() {
    setState(() {
      _mount = true;
      _visible = true;
    });
    shiftSubtitle();
    _timer?.cancel();
    _timer = Timer(controlsHoverDuration, () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
        unshiftSubtitle();
      }
    });
  }

  void onExit() {
    setState(() {
      _visible = false;
    });
    unshiftSubtitle();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: const Color(0x00000000),
        hoverColor: const Color(0x00000000),
        splashColor: const Color(0x00000000),
        highlightColor: const Color(0x00000000),
      ),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
              VideoContentView.currentState.play(),
          const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
              VideoContentView.currentState.pause(),
          const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
              VideoContentView.currentState.playOrPause(),
          const SingleActivator(LogicalKeyboardKey.mediaTrackNext):
              VideoContentView.currentState.nextItem,
          const SingleActivator(LogicalKeyboardKey.bracketLeft):
              VideoContentView.currentState.nextItem,
          const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious):
              VideoContentView.currentState.prevItem,
          const SingleActivator(LogicalKeyboardKey.bracketRight):
              VideoContentView.currentState.prevItem,
          const SingleActivator(LogicalKeyboardKey.space): () =>
              VideoContentView.currentState.playOrPause(),
          const SingleActivator(LogicalKeyboardKey.keyJ): () {
            VideoContentView.currentState.seek(
              VideoContentView.currentState.playerState.position -
                  const Duration(seconds: 60),
            );
          },
          const SingleActivator(LogicalKeyboardKey.keyI): () {
            VideoContentView.currentState.seek(
              VideoContentView.currentState.playerState.position +
                  const Duration(seconds: 60),
            );
          },
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
            VideoContentView.currentState.seek(
              VideoContentView.currentState.playerState.position -
                  const Duration(seconds: 10),
            );
          },
          const SingleActivator(LogicalKeyboardKey.arrowRight): () {
            VideoContentView.currentState.seek(
              VideoContentView.currentState.playerState.position +
                  const Duration(seconds: 10),
            );
          },
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            final volume =
                VideoContentView.currentState.playerState.volume + .05;
            VideoContentView.currentState.setVolume(volume.clamp(0.0, 1.0));
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            final volume =
                VideoContentView.currentState.playerState.volume - .05;
            VideoContentView.currentState.setVolume(volume.clamp(0.0, 1.0));
          },
          // const SingleActivator(LogicalKeyboardKey.keyF): () =>
          //     toggleFullscreen(context),
          // const SingleActivator(LogicalKeyboardKey.enter): () =>
          //     enterFullscreen(context),
          // const SingleActivator(LogicalKeyboardKey.escape): () =>
          //     exitFullscreen(context),
        },

        /// Add [Directionality] to ltr to avoid wrong animation of sides.
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Focus(
            autofocus: true,
            child: Material(
              elevation: 0.0,
              borderOnForeground: false,
              animationDuration: Duration.zero,
              color: const Color(0x00000000),
              shadowColor: const Color(0x00000000),
              surfaceTintColor: const Color(0x00000000),
              child: Listener(
                onPointerSignal: (e) {
                  if (e is PointerScrollEvent) {
                    if (e.delta.dy > 0) {
                      VideoContentView.currentState.volumeDown();
                    } else if (e.delta.dy < 0) {
                      VideoContentView.currentState.volumeUp();
                    }
                  }
                },
                child: GestureDetector(
                  onTapUp: (e) {
                    final now = DateTime.now();
                    final difference = now.difference(_last);
                    _last = now;
                    if (difference < const Duration(milliseconds: 400)) {
                      // toggleFullscreen(context);
                    } else {
                      VideoContentView.currentState.playOrPause();
                    }
                  },
                  onPanUpdate: (e) {
                    if (e.delta.dy > 0) {
                      VideoContentView.currentState.volumeDown();
                    } else if (e.delta.dy < 0) {
                      VideoContentView.currentState.volumeUp();
                    }
                  },
                  child: MouseRegion(
                    cursor: _visible
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.none,
                    onHover: (_) => onHover(),
                    onEnter: (_) => onEnter(),
                    onExit: (_) => onExit(),
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          curve: Curves.easeInOut,
                          opacity: _visible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          onEnd: () {
                            if (!_visible) {
                              setState(() {
                                _mount = false;
                              });
                            }
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Top gradient.
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.0, 0.2],
                                    colors: [
                                      Color(0x61000000),
                                      Color(0x00000000),
                                    ],
                                  ),
                                ),
                              ),
                              // Bottom gradient.
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.5, 1.0],
                                    colors: [
                                      Color(0x00000000),
                                      Color(0x61000000),
                                    ],
                                  ),
                                ),
                              ),
                              if (_mount)
                                // top bar
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: buttonBarHeight,
                                      margin: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const ExitButton(),
                                          const SizedBox(width: 8),
                                          const MediaTitle(),
                                          const PlayerErrorPopup(),
                                          const PlayerPlaylistButton(),
                                        ],
                                      ),
                                    ),
                                    // Only display [primaryButtonBar] if [buffering] is false.
                                    Spacer(),
                                    Transform.translate(
                                      offset: const Offset(0.0, 16.0),
                                      child: _DesktopVideoControlsSeekBar(
                                        onSeekStart: () {
                                          _timer?.cancel();
                                        },
                                        onSeekEnd: () {
                                          _timer = Timer(
                                            controlsHoverDuration,
                                            () {
                                              if (mounted) {
                                                setState(() {
                                                  _visible = false;
                                                });
                                                unshiftSubtitle();
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    // botton bar
                                    Container(
                                      height: buttonBarHeight,
                                      margin: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SkipPrevButton(),
                                          const PlayOrPauseButton(),
                                          const SkipNextButton(),
                                          const _DesktopVideoControlsVolumeButton(),
                                          const DesktopVideoControlsPositionIndicator(),
                                          const Spacer(),
                                          // const TrackSelector(),
                                          const SourceSelector(),
                                          const PlayerSettingsButton(),
                                          // if (!isFullscreen(context))
                                          //   _PIPButton(
                                          //     onPipEnter: widget.onPipEnter,
                                          //   ),
                                          // const PlayerFullscreenButton(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Buffering Indicator.
                        IgnorePointer(
                          child: Column(
                            children: [
                              Container(
                                height: buttonBarHeight,
                                margin: const EdgeInsets.all(8),
                              ),
                              Expanded(
                                child: Center(
                                  child: Center(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0.0,
                                        end: _buffering ? 1.0 : 0.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
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
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: buttonBarHeight,
                                margin: const EdgeInsets.all(8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// SEEK BAR

/// Material design seek bar.
class _DesktopVideoControlsSeekBar extends StatefulWidget {
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;

  const _DesktopVideoControlsSeekBar({this.onSeekStart, this.onSeekEnd});

  @override
  _DesktopVideoControlsSeekBarState createState() =>
      _DesktopVideoControlsSeekBarState();
}

class _DesktopVideoControlsSeekBarState
    extends State<_DesktopVideoControlsSeekBar> {
  static final barColor = const Color(0x3DFFFFFF);
  static const seekBarThumbSize = 12.0;

  bool hover = false;
  bool click = false;
  double slider = 0.0;

  bool playing = VideoContentView.currentState.playerState.isPlaying;
  Duration position = VideoContentView.currentState.playerState.position;
  Duration duration = VideoContentView.currentState.playerState.duration;
  Duration buffer = VideoContentView.currentState.playerState.lastBuffer;

  StreamSubscription? _subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _subscription = VideoContentView.currentState.playerStream.listen((event) {
      if (playing != event.isPlaying ||
          position != event.position ||
          duration != event.duration ||
          buffer != event.lastBuffer) {
        setState(() {
          playing = event.isPlaying;
          position = event.position;
          duration = event.duration;
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

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
    VideoContentView.currentState.seek(duration * slider);
  }

  void onPointerDown() {
    widget.onSeekStart?.call();
    setState(() {
      click = true;
    });
  }

  void onPointerUp() {
    widget.onSeekEnd?.call();
    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      click = false;
      position = duration * slider;
    });
    VideoContentView.currentState.seek(duration * slider);
  }

  void onHover(PointerHoverEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onEnter(PointerEnterEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onExit(PointerExitEvent e, BoxConstraints constraints) {
    setState(() {
      hover = false;
      slider = 0.0;
    });
  }

  /// Returns the current playback position in percentage.
  double get positionPercent {
    if (position == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = position.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  /// Returns the current playback buffer position in percentage.
  double get bufferPercent {
    if (buffer == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = buffer.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.none,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) => MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => onHover(e, constraints),
          onEnter: (e) => onEnter(e, constraints),
          onExit: (e) => onExit(e, constraints),
          child: Listener(
            onPointerMove: (e) => onPointerMove(e, constraints),
            onPointerDown: (e) => onPointerDown(),
            onPointerUp: (e) => onPointerUp(),
            child: Container(
              color: const Color(0x00000000),
              width: constraints.maxWidth,
              height: 36.0,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedContainer(
                    width: constraints.maxWidth,
                    height: hover ? 5.6 : 3.2,
                    alignment: Alignment.centerLeft,
                    duration: const Duration(milliseconds: 150),
                    color: barColor,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          width: constraints.maxWidth * slider,
                          color: barColor,
                        ),
                        Container(
                          width: constraints.maxWidth * bufferPercent,
                          color: barColor,
                        ),
                        Container(
                          width: click
                              ? constraints.maxWidth * slider
                              : constraints.maxWidth * positionPercent,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: click
                        ? (constraints.maxWidth - seekBarThumbSize / 2) * slider
                        : (constraints.maxWidth - seekBarThumbSize / 2) *
                              positionPercent,
                    child: AnimatedContainer(
                      width: hover || click ? seekBarThumbSize : 0.0,
                      height: hover || click ? seekBarThumbSize : 0.0,
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          seekBarThumbSize / 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// BUTTON: VOLUME

/// MaterialDesktop design volume button & slider.
class _DesktopVideoControlsVolumeButton extends StatefulWidget {
  const _DesktopVideoControlsVolumeButton();

  @override
  _DesktopVideoControlsVolumeButtonState createState() =>
      _DesktopVideoControlsVolumeButtonState();
}

class _DesktopVideoControlsVolumeButtonState
    extends State<_DesktopVideoControlsVolumeButton>
    with SingleTickerProviderStateMixin {
  static final volumeBarTransitionDuration = const Duration(milliseconds: 150);

  late double volume = VideoContentView.currentState.playerState.volume;

  StreamSubscription? _subscription;

  bool hover = false;

  bool mute = false;
  double _volume = 0.0;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _subscription = VideoContentView.currentState.playerStream.listen((event) {
      if (volume != event.volume) {
        setState(() {
          volume = event.volume;
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
    return MouseRegion(
      onEnter: (e) {
        setState(() {
          hover = true;
        });
      },
      onExit: (e) {
        setState(() {
          hover = false;
        });
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy < 0) {
              VideoContentView.currentState.volumeUp();
            }
            if (event.scrollDelta.dy > 0) {
              VideoContentView.currentState.volumeDown();
            }
          }
        },
        child: Row(
          children: [
            const SizedBox(width: 4.0),
            IconButton(
              onPressed: () async {
                if (mute) {
                  await VideoContentView.currentState.setVolume(_volume);
                  mute = !mute;
                }
                // https://github.com/media-kit/media-kit/pull/250#issuecomment-1605588306
                else if (volume == 0.0) {
                  _volume = 1.0;
                  await VideoContentView.currentState.setVolume(1.0);
                  mute = false;
                } else {
                  _volume = volume;
                  await VideoContentView.currentState.setVolume(0.0);
                  mute = !mute;
                }

                setState(() {});
              },
              color: Colors.white,
              icon: AnimatedSwitcher(
                duration: volumeBarTransitionDuration,
                child: volume == 0.0
                    ? const Icon(
                        Icons.volume_off,
                        key: ValueKey(Icons.volume_off),
                      )
                    : volume < 0.5
                    ? const Icon(
                        Icons.volume_down,
                        key: ValueKey(Icons.volume_down),
                      )
                    : const Icon(
                        Icons.volume_up,
                        key: ValueKey(Icons.volume_up),
                      ),
              ),
            ),
            AnimatedOpacity(
              opacity: hover ? 1.0 : 0.0,
              duration: volumeBarTransitionDuration,
              child: AnimatedContainer(
                width: hover ? 82.0 : 12.0,
                duration: volumeBarTransitionDuration,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 12.0),
                      SizedBox(
                        width: 52.0,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 1.2,
                            inactiveTrackColor: const Color(0x3DFFFFFF),
                            activeTrackColor: Colors.white,
                            thumbColor: Colors.white,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                              elevation: 0.0,
                              pressedElevation: 0.0,
                            ),
                            trackShape: _CustomTrackShape(),
                            overlayColor: const Color(0x00000000),
                          ),
                          child: Slider(
                            value: volume.clamp(0.0, 1.0),
                            onChanged: (value) async {
                              await VideoContentView.currentState.setVolume(
                                value,
                              );
                              mute = false;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 18.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// POSITION INDICATOR

/// MaterialDesktop design position indicator.
class DesktopVideoControlsPositionIndicator extends StatefulWidget {
  const DesktopVideoControlsPositionIndicator({super.key});

  @override
  DesktopVideoControlsPositionIndicatorState createState() =>
      DesktopVideoControlsPositionIndicatorState();
}

class DesktopVideoControlsPositionIndicatorState
    extends State<DesktopVideoControlsPositionIndicator> {
  late Duration position = VideoContentView.currentState.playerState.position;
  late Duration duration = VideoContentView.currentState.playerState.duration;

  StreamSubscription? _subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _subscription = VideoContentView.currentState.playerStream.listen((event) {
      if (position != event.position || duration != event.duration) {
        setState(() {
          position = event.position;
          duration = event.duration;
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
    return Text(
      '${formatDuration(position)} / ${formatDuration(duration)}',
      style: TextStyle(height: 1.0, fontSize: 12.0, color: Colors.white),
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final height = sliderTheme.trackHeight;
    final left = offset.dx;
    final top = offset.dy + (parentBox.size.height - height!) / 2;
    final width = parentBox.size.width;
    return Rect.fromLTWH(left, top, width, height);
  }
}

class _PIPButton extends StatelessWidget {
  final VoidCallback onPipEnter;

  const _PIPButton({required this.onPipEnter});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPipEnter,
      icon: const Icon(Symbols.pip),
      color: Colors.white,
    );
  }
}
