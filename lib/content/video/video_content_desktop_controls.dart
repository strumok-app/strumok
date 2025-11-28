import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:strumok/content/video/track_selector.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:strumok/utils/fullscrean.dart';
import 'package:strumok/utils/text.dart';

class VideoContentDesktopControls extends StatefulWidget {
  final VoidCallback onPipEnter;
  const VideoContentDesktopControls({super.key, required this.onPipEnter});

  @override
  State<VideoContentDesktopControls> createState() =>
      _VideoContentDesktopControlsState();
}

class _VideoContentDesktopControlsState
    extends State<VideoContentDesktopControls> {
  static final controlsHoverDuration = const Duration(seconds: 3);
  static const subtitleVerticalShiftOffset = 96.0;
  static const buttonBarHeight = 56.0;
  static const pointerEventsPad = 100;

  late bool _mount = true;
  late bool _visible = true;

  late bool _buffering = true;
  TapDownDetails? _lastTapDetails;
  StreamSubscription? _subscription;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= videoContentController(context).videoBackendStateStream
        .listen((event) {
          final newBuffering = event.showBuffering;

          if (_buffering != newBuffering) {
            setState(() {
              _buffering = newBuffering;
            });
          }
        });

    _timer = Timer(controlsHoverDuration, _hideUI);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void shiftSubtitle() {
    videoContentController(context).subtitlePaddings.value =
        EdgeInsets.fromLTRB(0.0, 0.0, 0.0, subtitleVerticalShiftOffset);
  }

  void unshiftSubtitle() {
    videoContentController(context).subtitlePaddings.value = EdgeInsets.zero;
  }

  void onHover() {
    if (_visible) {
      return;
    }

    setState(() {
      _mount = true;
      _visible = true;
    });

    shiftSubtitle();
    _timer?.cancel();
    _timer = Timer(controlsHoverDuration, _hideUI);
  }

  void _hideUI() {
    if (mounted) {
      setState(() {
        _visible = false;
        _mount = false;
      });
      unshiftSubtitle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screanSize = MediaQuery.sizeOf(context);
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
              videoContentController(context).play(),
          const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
              videoContentController(context).pause(),
          const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
              videoContentController(context).playOrPause(),
          const SingleActivator(LogicalKeyboardKey.mediaTrackNext):
              videoContentController(context).nextItem,
          const SingleActivator(LogicalKeyboardKey.bracketRight):
              videoContentController(context).nextItem,
          const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious):
              videoContentController(context).prevItem,
          const SingleActivator(LogicalKeyboardKey.bracketLeft):
              videoContentController(context).prevItem,
          const SingleActivator(LogicalKeyboardKey.space): () =>
              videoContentController(context).playOrPause(),
          const SingleActivator(LogicalKeyboardKey.keyJ): () {
            videoContentController(
              context,
            ).seekBackward(const Duration(seconds: 60));
          },
          const SingleActivator(LogicalKeyboardKey.keyI): () {
            videoContentController(
              context,
            ).seekForward(const Duration(seconds: 60));
          },
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
            videoContentController(
              context,
            ).seekBackward(const Duration(seconds: 10));
          },
          const SingleActivator(LogicalKeyboardKey.arrowRight): () {
            videoContentController(
              context,
            ).seekForward(const Duration(seconds: 10));
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            videoContentController(context).volumeDown();
          },
          const SingleActivator(LogicalKeyboardKey.keyF): () =>
              toggleFullscreen(),
          const SingleActivator(LogicalKeyboardKey.enter): () =>
              enterFullscreen(),
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              exitFullscreen(),
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
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              child: Listener(
                onPointerSignal: (e) {
                  if (e is PointerScrollEvent) {
                    if (e.delta.dy > 0) {
                      videoContentController(context).volumeDown();
                    } else if (e.delta.dy < 0) {
                      videoContentController(context).volumeUp();
                    }
                  }
                },
                child: GestureDetector(
                  onTapDown: (details) => {_lastTapDetails = details},
                  onDoubleTap: () {
                    if (_isTapPositionOutOfPads(screanSize)) {
                      return;
                    }
                    toggleFullscreen();
                  },
                  onTap: () {
                    if (_isTapPositionOutOfPads(screanSize)) {
                      return;
                    }
                    videoContentController(context).playOrPause();
                  },
                  onPanUpdate: (e) {
                    if (e.delta.dy > 0) {
                      videoContentController(context).volumeDown();
                    } else if (e.delta.dy < 0) {
                      videoContentController(context).volumeUp();
                    }
                  },
                  child: MouseRegion(
                    cursor: _visible
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.none,
                    onHover: (_) => onHover(),
                    onEnter: (_) => onHover(),
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          curve: Curves.easeInOut,
                          opacity: _visible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
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
                                            _hideUI,
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
                                          const TrackSelector(),
                                          const SourceSelector(),
                                          const PlayerSettingsButton(),
                                          _PIPButton(
                                            onPipEnter: widget.onPipEnter,
                                          ),
                                          const _DesktopPlayerFullscreenButton(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Buffering Indicator.
                        Column(
                          children: [
                            Container(
                              height: buttonBarHeight,
                              margin: const EdgeInsets.all(8),
                            ),
                            Expanded(
                              child: Center(
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: _buffering ? 1.0 : 0.0,
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
                                    color: Color(0xFFFFFFFF),
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

  bool _isTapPositionOutOfPads(Size screanSize) {
    return _lastTapDetails!.globalPosition.dy < pointerEventsPad ||
        _lastTapDetails!.globalPosition.dy >
            screanSize.height - pointerEventsPad;
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

  late bool playing = videoContentController(
    context,
  ).videoBackendState.isPlaying;
  late Duration position = videoContentController(
    context,
  ).videoBackendState.position;
  late Duration duration = videoContentController(
    context,
  ).videoBackendState.duration;
  late Duration buffer = videoContentController(
    context,
  ).videoBackendState.buffered;

  StreamSubscription? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= videoContentController(context).videoBackendStateStream
        .listen((event) {
          if (playing != event.isPlaying ||
              position != event.position ||
              duration != event.duration ||
              buffer != event.buffered) {
            setState(() {
              playing = event.isPlaying;
              position = event.position;
              duration = event.duration;
              buffer = event.buffered;
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
    videoContentController(context).seekTo(duration * slider);
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
    if (mounted) {
      videoContentController(context).seekTo(duration * slider);
    }
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
              color: Colors.transparent,
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

  late double volume = videoContentController(context).videoBackendState.volume;

  StreamSubscription? _subscription;

  bool hover = false;

  bool mute = false;
  double _volume = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= videoContentController(context).videoBackendStateStream
        .listen((event) {
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
              videoContentController(context).volumeUp();
            }
            if (event.scrollDelta.dy > 0) {
              videoContentController(context).volumeDown();
            }
          }
        },
        child: Row(
          children: [
            const SizedBox(width: 4.0),
            IconButton(
              onPressed: () async {
                if (mute) {
                  await videoContentController(context).setVolume(_volume);
                  mute = !mute;
                }
                // https://github.com/media-kit/media-kit/pull/250#issuecomment-1605588306
                else if (volume == 0.0) {
                  _volume = 1.0;
                  await videoContentController(context).setVolume(1.0);
                  mute = false;
                } else {
                  _volume = volume;
                  await videoContentController(context).setVolume(0.0);
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
                            overlayColor: Colors.transparent,
                          ),
                          child: Slider(
                            value: volume.clamp(0.0, 1.0),
                            onChanged: (value) async {
                              await videoContentController(
                                context,
                              ).setVolume(value);
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
  late Duration position = videoContentController(
    context,
  ).videoBackendState.position;
  late Duration duration = videoContentController(
    context,
  ).videoBackendState.duration;

  StreamSubscription? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= videoContentController(context).videoBackendStateStream
        .listen((event) {
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

class _DesktopPlayerFullscreenButton extends StatelessWidget {
  const _DesktopPlayerFullscreenButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: toggleFullscreen,
      icon: const Icon(Icons.fullscreen),
      color: Colors.white,
    );
  }
}
