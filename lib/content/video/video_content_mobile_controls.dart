import 'dart:async';

import 'package:flutter/material.dart';
import 'package:strumok/content/video/track_selector.dart';
import 'package:strumok/content/video/video_content_controller.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/video_source_selector.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:strumok/utils/text.dart';
import 'package:volume_controller/volume_controller.dart';

/// {@macro material_video_controls}
class VideoContentMobileControls extends StatefulWidget {
  const VideoContentMobileControls({super.key});

  @override
  State<VideoContentMobileControls> createState() =>
      _VideoContentMobileControlsState();
}

/// {@macro material_video_controls}
class _VideoContentMobileControlsState
    extends State<VideoContentMobileControls> {
  static final controlsHoverDuration = const Duration(seconds: 3);
  static final controlsTransitionDuration = const Duration(milliseconds: 300);

  static const subtitleVerticalShiftOffset = 48.0;

  static const verticalGestureSensitivity = 100;
  static const horizontalGestureSensitivity = 1000;
  static final seekOnDoubleTapLayoutTapsRatios = const [1, 1, 1];
  static final seekOnDoubleTapLayoutWidgetRatios = const [1, 1, 1];
  static final seekOnDoubleTapBackwardDuration = const Duration(seconds: 10);
  static final seekOnDoubleTapForwardDuration = const Duration(seconds: 10);

  static const speedUpFactor = 2.0;

  static final topButtonBarMargin = const EdgeInsets.only(
    left: 20,
    right: 8,
    bottom: 8,
    top: 8,
  );
  static const buttonBarHeight = 56.0;
  static final bottomButtonBarMargin = const EdgeInsets.all(8);

  late bool _mount = false;
  late bool _visible = false;
  Timer? _timer;

  double _brightnessValue = 0.0;
  bool _brightnessIndicator = false;
  Timer? _brightnessTimer;
  double _currentRate = 1.0;
  double _volumeValue = 0.0;
  bool _volumeIndicator = false;
  Timer? _volumeTimer;
  // The default event stream in package:volume_controller is buggy.
  bool _volumeInterceptEventStream = false;

  Offset _dragInitialDelta =
      Offset.zero; // Initial position for horizontal drag
  int swipeDuration = 0; // Duration to seek in video
  bool showSwipeDuration = false; // Whether to show the seek duration overlay

  bool _speedUpIndicator = false;
  late bool _buffering = true;
  final VolumeController _volumeController = VolumeController.instance;

  bool _mountSeekBackwardButton = false;
  bool _mountSeekForwardButton = false;
  bool _hideSeekBackwardButton = false;
  bool _hideSeekForwardButton = false;
  Timer? _timerSeekBackwardButton;
  Timer? _timerSeekForwardButton;

  final ValueNotifier<Duration> _seekBarDeltaValueNotifier =
      ValueNotifier<Duration>(Duration.zero);

  StreamSubscription? _subscription;

  Offset? _tapPosition;

  void _handleDoubleTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
  }

  void _handleLongPress() {
    setState(() {
      _speedUpIndicator = true;
    });
    final controller = videoContentController(context);
    _currentRate = controller.playerState.playbackSpeed;
    controller.setRate(_currentRate * speedUpFactor);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _speedUpIndicator = false;
    });
    videoContentController(context).setRate(_currentRate);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= videoContentController(context).playerStream.listen((
      event,
    ) {
      final newBuffering = event.showBuffering;

      if (_buffering != newBuffering) {
        setState(() {
          _buffering = newBuffering;
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

    // --------------------------------------------------
    // package:volume_controller
    Future.microtask(() async {
      try {
        _volumeController.showSystemUI = false;
        _volumeValue = await _volumeController.getVolume();
        _volumeController.addListener((value) {
          if (mounted && !_volumeInterceptEventStream) {
            setState(() {
              _volumeValue = value;
            });
          }
        });
      } catch (_) {}
    });
    // --------------------------------------------------
    // --------------------------------------------------
    // package:screen_brightness
    Future.microtask(() async {
      try {
        _brightnessValue = await ScreenBrightnessPlatform.instance.application;
        ScreenBrightnessPlatform.instance.onApplicationScreenBrightnessChanged
            .listen((value) {
              if (mounted) {
                setState(() {
                  _brightnessValue = value;
                });
              }
            });
      } catch (_) {}
    });
    // --------------------------------------------------
  }

  @override
  void dispose() {
    _subscription?.cancel();
    // --------------------------------------------------
    // package:screen_brightness
    Future.microtask(() async {
      try {
        await ScreenBrightnessPlatform.instance
            .resetApplicationScreenBrightness();
      } catch (_) {}
    });
    // --------------------------------------------------
    _timerSeekBackwardButton?.cancel();
    _timerSeekForwardButton?.cancel();
    super.dispose();
  }

  void shiftSubtitle() {
    videoContentController(context).subtitlePaddings.value =
        EdgeInsets.fromLTRB(0.0, 0.0, 0.0, subtitleVerticalShiftOffset);
  }

  void unshiftSubtitle() {
    videoContentController(context).subtitlePaddings.value = EdgeInsets.zero;
  }

  void onTap() {
    if (!_visible) {
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
    } else {
      setState(() {
        _visible = false;
      });
      unshiftSubtitle();
      _timer?.cancel();
    }
  }

  void onDoubleTapSeekBackward() {
    setState(() {
      _mountSeekBackwardButton = true;
    });
  }

  void onDoubleTapSeekForward() {
    setState(() {
      _mountSeekForwardButton = true;
    });
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_dragInitialDelta == Offset.zero) {
      _dragInitialDelta = details.localPosition;
      return;
    }

    final diff = _dragInitialDelta.dx - details.localPosition.dx;
    final duration = videoContentController(
      context,
    ).playerState.duration.inSeconds;
    final position = videoContentController(
      context,
    ).playerState.position.inSeconds;

    final seconds = -(diff * duration / horizontalGestureSensitivity).round();
    final relativePosition = position + seconds;

    if (relativePosition <= duration && relativePosition >= 0) {
      setState(() {
        swipeDuration = seconds;
        showSwipeDuration = true;
        _seekBarDeltaValueNotifier.value = Duration(seconds: seconds);
      });
    }
  }

  void onHorizontalDragEnd() {
    if (swipeDuration != 0) {
      videoContentController(
        context,
      ).seekForward(Duration(seconds: swipeDuration));
    }

    setState(() {
      _dragInitialDelta = Offset.zero;
      showSwipeDuration = false;
    });
  }

  bool _isInSegment(double localX, int segmentIndex) {
    // Local variable with the list of ratios
    List<int> segmentRatios = seekOnDoubleTapLayoutTapsRatios;

    int totalRatios = segmentRatios.reduce((a, b) => a + b);

    double segmentWidthMultiplier = widgetWidth(context) / totalRatios;
    double start = 0;
    double end;

    for (int i = 0; i < segmentRatios.length; i++) {
      end = start + (segmentWidthMultiplier * segmentRatios[i]);

      // Check if the current index matches the segmentIndex and if localX falls within it
      if (i == segmentIndex && localX >= start && localX <= end) {
        return true;
      }

      // Set the start of the next segment
      start = end;
    }

    // If localX does not fall within the specified segment
    return false;
  }

  bool _isInRightSegment(double localX) {
    return _isInSegment(localX, 2);
  }

  bool _isInLeftSegment(double localX) {
    return _isInSegment(localX, 0);
  }

  void _handlePointerDown(PointerDownEvent event) {
    onTap();
  }

  Future<void> setVolume(double value) async {
    // --------------------------------------------------
    // package:volume_controller
    try {
      _volumeController.setVolume(value);
    } catch (_) {}
    setState(() {
      _volumeValue = value;
      _volumeIndicator = true;
      _volumeInterceptEventStream = true;
    });
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _volumeIndicator = false;
          _volumeInterceptEventStream = false;
        });
      }
    });
    // --------------------------------------------------
  }

  Future<void> setBrightness(double value) async {
    // --------------------------------------------------
    // package:screen_brightness
    try {
      await ScreenBrightnessPlatform.instance.setApplicationScreenBrightness(
        value,
      );
    } catch (_) {}
    setState(() {
      _brightnessIndicator = true;
    });
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _brightnessIndicator = false;
        });
      }
    });
    // --------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    assert(
      seekOnDoubleTapLayoutTapsRatios.length == 3,
      "The number of seekOnDoubleTapLayoutTapsRatios must be 3, i.e. [1, 1, 1]",
    );
    assert(
      seekOnDoubleTapLayoutWidgetRatios.length == 3,
      "The number of seekOnDoubleTapLayoutWidgetRatios must be 3, i.e. [1, 1, 1]",
    );
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Colors.black,
        hoverColor: Colors.black,
        splashColor: Colors.black,
        highlightColor: Colors.black,
      ),

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
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Controls:
                AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: _visible ? 1.0 : 0.0,
                  duration: controlsTransitionDuration,
                  onEnd: () {
                    setState(() {
                      if (!_visible) {
                        _mount = false;
                      }
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Container(color: const Color(0x66000000)),
                      ),
                      // We are adding 16.0 boundary around the actual controls (which contain the vertical drag gesture detectors).
                      // This will make the hit-test on edges (e.g. swiping to: show status-bar, show navigation-bar, go back in navigation) not activate the swipe gesture annoyingly.
                      Positioned.fill(
                        left: 16.0,
                        top: 16.0,
                        right: 16.0,
                        bottom: 16.0 + subtitleVerticalShiftOffset,
                        child: Listener(
                          onPointerDown: (event) => _handlePointerDown(event),
                          child: GestureDetector(
                            onDoubleTapDown: _handleDoubleTapDown,
                            onLongPress: _handleLongPress,
                            onLongPressEnd: _handleLongPressEnd,
                            onDoubleTap: () {
                              if (_tapPosition == null) {
                                return;
                              }
                              if (_isInRightSegment(_tapPosition!.dx)) {
                                onDoubleTapSeekForward();
                              } else if (_isInLeftSegment(_tapPosition!.dx)) {
                                onDoubleTapSeekBackward();
                              }
                            },
                            onHorizontalDragUpdate: onHorizontalDragUpdate,
                            onHorizontalDragEnd: (details) {
                              onHorizontalDragEnd();
                            },
                            onVerticalDragUpdate: (e) async {
                              final delta = e.delta.dy;
                              final Offset position = e.localPosition;

                              if (position.dx <= widgetWidth(context) / 2) {
                                // Left side of screen swiped
                                final brightness =
                                    _brightnessValue -
                                    delta / verticalGestureSensitivity;
                                final result = brightness.clamp(0.0, 1.0);
                                setBrightness(result);
                              } else {
                                // Right side of screen swiped
                                final volume =
                                    _volumeValue -
                                    delta / verticalGestureSensitivity;
                                final result = volume.clamp(0.0, 1.0);
                                setVolume(result);
                              }
                            },
                            child: Container(color: const Color(0x00000000)),
                          ),
                        ),
                      ),
                      if (_mount)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: buttonBarHeight,
                              margin: topButtonBarMargin,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const MediaTitle(),
                                  const Spacer(),
                                  const PlayerPlaylistButton(),
                                ],
                              ),
                            ),
                            // Only display [primaryButtonBar] if [buffering] is false.
                            Expanded(
                              child: AnimatedOpacity(
                                curve: Curves.easeInOut,
                                opacity: _buffering ? 0.0 : 1.0,
                                duration: controlsTransitionDuration,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Spacer(flex: 2),
                                      const SkipPrevButton(iconSize: 36.0),
                                      const Spacer(),
                                      const PlayOrPauseButton(iconSize: 48.0),
                                      const Spacer(),
                                      const SkipNextButton(iconSize: 36.0),
                                      const Spacer(flex: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                _MobileControlSeekBar(
                                  onSeekStart: () {
                                    _timer?.cancel();
                                  },
                                  onSeekEnd: () {
                                    _timer = Timer(controlsHoverDuration, () {
                                      if (mounted) {
                                        setState(() {
                                          _visible = false;
                                        });
                                        unshiftSubtitle();
                                      }
                                    });
                                  },
                                ),
                                Container(
                                  height: buttonBarHeight,
                                  margin: bottomButtonBarMargin,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const _MobileControlsPositionIndicator(),
                                      const Spacer(),
                                      const TrackSelector(),
                                      const SourceSelector(),
                                      const PlayerSettingsButton(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Double-Tap Seek Seek-Bar:
                if (!_mount)
                  if (_mountSeekBackwardButton ||
                      _mountSeekForwardButton ||
                      showSwipeDuration)
                    Column(
                      children: [
                        const Spacer(),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            _MobileControlSeekBar(
                              delta: _seekBarDeltaValueNotifier,
                            ),
                            Container(
                              height: buttonBarHeight,
                              margin: bottomButtonBarMargin,
                            ),
                          ],
                        ),
                      ],
                    ),
                // Buffering Indicator.
                IgnorePointer(
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _buffering ? 1.0 : 0.0,
                      ),
                      duration: controlsTransitionDuration,
                      builder: (context, value, child) {
                        // Only mount the buffering indicator if the opacity is greater than 0.0.
                        // This has been done to prevent redundant resource usage in [CircularProgressIndicator].
                        if (value > 0.0) {
                          return Opacity(opacity: value, child: child!);
                        }
                        return const SizedBox.shrink();
                      },
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Volume Indicator.
                IgnorePointer(
                  child: AnimatedOpacity(
                    curve: Curves.easeInOut,
                    opacity: _volumeIndicator ? 1.0 : 0.0,
                    duration: controlsTransitionDuration,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0x88000000),
                        borderRadius: BorderRadius.circular(64.0),
                      ),
                      height: 52.0,
                      width: 108.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 52.0,
                            width: 42.0,
                            alignment: Alignment.centerRight,
                            child: Icon(
                              _volumeValue == 0.0
                                  ? Icons.volume_off
                                  : _volumeValue < 0.5
                                  ? Icons.volume_down
                                  : Icons.volume_up,
                              color: const Color(0xFFFFFFFF),
                              size: 24.0,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              '${(_volumeValue * 100.0).round()}%',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Brightness Indicator.
                IgnorePointer(
                  child: AnimatedOpacity(
                    curve: Curves.easeInOut,
                    opacity: _brightnessIndicator ? 1.0 : 0.0,
                    duration: controlsTransitionDuration,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0x88000000),
                        borderRadius: BorderRadius.circular(64.0),
                      ),
                      height: 52.0,
                      width: 108.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 52.0,
                            width: 42.0,
                            alignment: Alignment.centerRight,
                            child: Icon(
                              _brightnessValue < 1.0 / 3.0
                                  ? Icons.brightness_low
                                  : _brightnessValue < 2.0 / 3.0
                                  ? Icons.brightness_medium
                                  : Icons.brightness_high,
                              color: const Color(0xFFFFFFFF),
                              size: 24.0,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              '${(_brightnessValue * 100.0).round()}%',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Speedup Indicator.
                IgnorePointer(
                  child: Padding(
                    padding: MediaQuery.of(context).padding,
                    child: Column(
                      children: [
                        Container(
                          height: buttonBarHeight,
                          margin: topButtonBarMargin,
                        ),
                        Expanded(
                          child: AnimatedOpacity(
                            duration: controlsTransitionDuration,
                            opacity: _speedUpIndicator ? 1 : 0,
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0x88000000),
                                  borderRadius: BorderRadius.circular(64.0),
                                ),
                                height: 48.0,
                                width: 108.0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Text(
                                        '${speedUpFactor.toStringAsFixed(1)}x',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 48.0,
                                      width: 48.0 - 16.0,
                                      alignment: Alignment.centerRight,
                                      child: const Icon(
                                        Icons.fast_forward,
                                        color: Color(0xFFFFFFFF),
                                        size: 24.0,
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: buttonBarHeight,
                          margin: bottomButtonBarMargin,
                        ),
                      ],
                    ),
                  ),
                ),
                // Seek Indicator.
                IgnorePointer(
                  child: AnimatedOpacity(
                    duration: controlsTransitionDuration,
                    opacity: showSwipeDuration ? 1 : 0,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0x88000000),
                        borderRadius: BorderRadius.circular(64.0),
                      ),
                      height: 52.0,
                      width: 108.0,
                      child: Text(
                        swipeDuration > 0
                            ? "+ ${formatDuration(Duration(seconds: swipeDuration.abs()))}"
                            : "- ${formatDuration(Duration(seconds: swipeDuration.abs()))}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
                // Double-Tap Seek Button(s):
                if (_mountSeekBackwardButton || _mountSeekForwardButton)
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          flex: seekOnDoubleTapLayoutWidgetRatios[0],
                          child: _mountSeekBackwardButton
                              ? AnimatedOpacity(
                                  opacity: _hideSeekBackwardButton ? 0 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: _BackwardSeekIndicator(
                                    duration: seekOnDoubleTapBackwardDuration,
                                    onChanged: (value) {
                                      _seekBarDeltaValueNotifier.value = -value;
                                    },
                                    onSubmitted: (value) {
                                      _timerSeekBackwardButton?.cancel();
                                      _timerSeekBackwardButton = Timer(
                                        const Duration(milliseconds: 200),
                                        () {
                                          setState(() {
                                            _hideSeekBackwardButton = false;
                                            _mountSeekBackwardButton = false;
                                          });
                                        },
                                      );

                                      setState(() {
                                        _hideSeekBackwardButton = true;
                                      });
                                      videoContentController(
                                        context,
                                      ).seekBackward(value);
                                    },
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        //Area in the middle where the double-tap seek buttons are ignored in
                        if (seekOnDoubleTapLayoutWidgetRatios[1] > 0)
                          Spacer(flex: seekOnDoubleTapLayoutWidgetRatios[1]),
                        Expanded(
                          flex: seekOnDoubleTapLayoutWidgetRatios[2],
                          child: _mountSeekForwardButton
                              ? AnimatedOpacity(
                                  opacity: _hideSeekForwardButton ? 0 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: _ForwardSeekIndicator(
                                    duration: seekOnDoubleTapForwardDuration,
                                    onChanged: (value) {
                                      _seekBarDeltaValueNotifier.value = value;
                                    },
                                    onSubmitted: (value) {
                                      _timerSeekForwardButton?.cancel();
                                      _timerSeekForwardButton = Timer(
                                        const Duration(milliseconds: 200),
                                        () {
                                          if (_hideSeekForwardButton) {
                                            setState(() {
                                              _hideSeekForwardButton = false;
                                              _mountSeekForwardButton = false;
                                            });
                                          }
                                        },
                                      );
                                      setState(() {
                                        _hideSeekForwardButton = true;
                                      });

                                      videoContentController(
                                        context,
                                      ).seekForward(value);
                                    },
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double widgetWidth(BuildContext context) =>
      (context.findRenderObject() as RenderBox).paintBounds.width;
}

// SEEK BAR

/// Material design seek bar.
class _MobileControlSeekBar extends StatefulWidget {
  final ValueNotifier<Duration>? delta;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;

  const _MobileControlSeekBar({this.delta, this.onSeekStart, this.onSeekEnd});

  @override
  _MobileControlSeekBarState createState() => _MobileControlSeekBarState();
}

class _MobileControlSeekBarState extends State<_MobileControlSeekBar> {
  static const seekBarThumbSize = 12.8;
  static const seekBarHeight = 12.8;
  static final barColor = const Color(0x3DFFFFFF);

  bool tapped = false;
  double slider = 0.0;

  late bool playing = videoContentController(context).playerState.isPlaying;
  late Duration position = videoContentController(context).playerState.position;
  late Duration duration = videoContentController(context).playerState.duration;
  late Duration buffer = videoContentController(context).playerState.lastBuffer;

  StreamSubscription? _subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void listener() {
    setState(() {
      final delta = widget.delta?.value ?? Duration.zero;
      position = videoContentController(context).playerState.position + delta;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.delta?.addListener(listener);
    _subscription ??= videoContentController(context).playerStream.listen((
      event,
    ) {
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
    widget.delta?.removeListener(listener);
    _subscription?.cancel();
    super.dispose();
  }

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
    if (mounted) {
      videoContentController(context).seekTo(duration * slider);
    }
  }

  void onPointerDown() {
    widget.onSeekStart?.call();
    setState(() {
      tapped = true;
    });
  }

  void onPointerUp() {
    widget.onSeekEnd?.call();
    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      tapped = false;
      position = duration * slider;
    });
    if (mounted) {
      videoContentController(context).seekTo(duration * slider);
    }
  }

  void onPanStart(DragStartDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPanDown(DragDownDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPanUpdate(DragUpdateDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
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
    final colorSchema = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.none,
      margin: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onHorizontalDragUpdate: (_) {},
            onPanStart: (e) => onPanStart(e, constraints),
            onPanDown: (e) => onPanDown(e, constraints),
            onPanUpdate: (e) => onPanUpdate(e, constraints),
            child: Listener(
              onPointerMove: (e) => onPointerMove(e, constraints),
              onPointerDown: (e) => onPointerDown(),
              onPointerUp: (e) => onPointerUp(),
              child: Container(
                color: Colors.transparent,
                width: constraints.maxWidth,
                alignment: Alignment.bottomCenter,
                height: 36.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: seekBarHeight,
                      alignment: Alignment.bottomLeft,
                      color: barColor,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            width: constraints.maxWidth * bufferPercent,
                            color: barColor,
                          ),
                          Container(
                            width: tapped
                                ? constraints.maxWidth * slider
                                : constraints.maxWidth * positionPercent,
                            color: colorSchema.primary,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: tapped
                          ? (constraints.maxWidth - seekBarThumbSize / 2) *
                                slider
                          : (constraints.maxWidth - seekBarThumbSize / 2) *
                                positionPercent,
                      bottom: -1.0 * seekBarThumbSize / 2 + seekBarHeight / 2,
                      child: Container(
                        width: seekBarThumbSize,
                        height: seekBarThumbSize,
                        decoration: BoxDecoration(
                          color: colorSchema.primary,
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
      ),
    );
  }
}

// POSITION INDICATOR

/// Material design position indicator.
class _MobileControlsPositionIndicator extends StatefulWidget {
  /// Overriden [TextStyle] for the [MaterialPositionIndicator].
  const _MobileControlsPositionIndicator();

  @override
  _MobileControlsPositionIndicatorState createState() =>
      _MobileControlsPositionIndicatorState();
}

class _MobileControlsPositionIndicatorState
    extends State<_MobileControlsPositionIndicator> {
  late Duration position = videoContentController(context).playerState.position;
  late Duration duration = videoContentController(context).playerState.duration;

  StreamSubscription? _subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscription ??= videoContentController(context).playerStream.listen((
      event,
    ) {
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

class _BackwardSeekIndicator extends StatefulWidget {
  final Duration duration;
  final void Function(Duration) onChanged;
  final void Function(Duration) onSubmitted;
  const _BackwardSeekIndicator({
    required this.duration,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_BackwardSeekIndicator> createState() => _BackwardSeekIndicatorState();
}

class _BackwardSeekIndicatorState extends State<_BackwardSeekIndicator> {
  late Duration value = widget.duration;

  Timer? timer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timer ??= Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
  }

  void increment() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
    widget.onChanged.call(value);
    setState(() {
      value += const Duration(seconds: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x88767676), Color(0x00767676)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        splashColor: const Color(0x44767676),
        onTap: increment,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fast_rewind,
                size: 24.0,
                color: Color(0xFFFFFFFF),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${value.inSeconds} seconds',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForwardSeekIndicator extends StatefulWidget {
  final Duration duration;
  final void Function(Duration) onChanged;
  final void Function(Duration) onSubmitted;
  const _ForwardSeekIndicator({
    required this.duration,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_ForwardSeekIndicator> createState() => _ForwardSeekIndicatorState();
}

class _ForwardSeekIndicatorState extends State<_ForwardSeekIndicator> {
  late Duration value = widget.duration;

  Timer? timer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timer ??= Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
  }

  void increment() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
    widget.onChanged.call(value);
    setState(() {
      value += const Duration(seconds: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x00767676), Color(0x88767676)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        splashColor: const Color(0x44767676),
        onTap: increment,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fast_forward,
                size: 24.0,
                color: Color(0xFFFFFFFF),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${value.inSeconds} seconds',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
