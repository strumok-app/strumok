import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:strumok/content/video/source_selector.dart';
import 'package:strumok/content/video/track_selector.dart';
import 'package:strumok/content/video/video_player_buttons.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/content/video/video_player_settings.dart';
import 'package:strumok/content/video/widgets.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/video_backend/video_backend.dart';
import 'package:volume_controller/volume_controller.dart';

const _fadeDuration = Duration(milliseconds: 300);
const _buttonBarHeight = 56.0;
const _topBarMargin = EdgeInsets.only(left: 20, right: 8, bottom: 8, top: 8);
const _bottomBarMargin = EdgeInsets.all(8);
const _white = Color(0xFFFFFFFF);
const _scrimColor = Color(0x99000000);
const _transparent = Color(0x00000000);
// Extra height so the bar gradients fade out softly instead of ending at the buttons.
const _scrimFade = 32.0;

enum _SeekDirection { backward, forward }

enum _Indicator { volume, brightness }

class VideoPlayerMobileControlsV2 extends StatefulWidget {
  const VideoPlayerMobileControlsV2({super.key});

  @override
  State<VideoPlayerMobileControlsV2> createState() =>
      _VideoPlayerMobileControlsV2State();
}

class _VideoPlayerMobileControlsV2State
    extends State<VideoPlayerMobileControlsV2> {
  static const _hideDelay = Duration(seconds: 3);
  static const _indicatorHideDelay = Duration(milliseconds: 200);
  static const _tapSeekCommitDelay = Duration(milliseconds: 400);
  static const _tapSeekStep = Duration(seconds: 10);
  static const _subtitleShift = 48.0;
  // Keeps system edge swipes (status bar, back gesture) from triggering player gestures.
  static const _edgeInset = 16.0;
  static const _verticalSensitivity = 100.0;
  static const _horizontalSensitivity = 1000.0;
  static const _speedUpFactor = 2.0;

  late VideoPlayerController _controller;
  VideoPlayerController? _listenedController;
  final _volumeController = VolumeController.instance;
  StreamSubscription<double>? _brightnessSubscription;

  // Error is shown by VideoView underneath; gestures must not cover its retry button.
  bool _hasError = false;

  // Controls overlay
  bool _controlsVisible = false;
  bool _controlsMounted = false;
  Timer? _hideTimer;

  // Volume / brightness
  double _volume = 0.0;
  double _brightness = 0.0;
  _Indicator? _indicator;
  Timer? _indicatorTimer;

  // Long press speed-up; non-null while active
  double? _rateBeforeSpeedUp;

  // Horizontal swipe seek
  double? _dragStartX;
  Duration? _swipeSeek;

  // Double tap seek
  Offset? _doubleTapPosition;
  _SeekDirection? _tapSeekDirection;
  Duration _tapSeekAmount = Duration.zero;
  Timer? _tapSeekTimer;

  Duration? get _seekPreview {
    if (_swipeSeek != null) return _swipeSeek;
    return switch (_tapSeekDirection) {
      _SeekDirection.forward => _tapSeekAmount,
      _SeekDirection.backward => -_tapSeekAmount,
      null => null,
    };
  }

  @override
  void initState() {
    super.initState();
    _initVolume();
    _initBrightness();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = videoContentController(context);

    if (_listenedController != _controller) {
      _listenedController?.videoBackend.removeListener(_onVideoBackendChanged);
      _listenedController = _controller;
      _controller.videoBackend.addListener(_onVideoBackendChanged);

      _hasError = _controller.videoBackend.value is AsyncError;
      if (_hasError) {
        _controlsMounted = true;
        _controlsVisible = true;
      }
    }
  }

  @override
  void dispose() {
    _listenedController?.videoBackend.removeListener(_onVideoBackendChanged);
    _hideTimer?.cancel();
    _indicatorTimer?.cancel();
    _tapSeekTimer?.cancel();
    _volumeController.removeListener();
    _brightnessSubscription?.cancel();
    _resetBrightness();
    super.dispose();
  }

  Future<void> _initVolume() async {
    try {
      _volumeController.showSystemUI = false;
      final volume = await _volumeController.getVolume();
      if (!mounted) return;
      setState(() => _volume = volume);
      _volumeController.addListener((value) {
        // System volume events are unreliable while we are changing it ourselves.
        if (mounted && _indicator != _Indicator.volume) {
          setState(() => _volume = value);
        }
      }, fetchInitialVolume: false);
    } catch (_) {}
  }

  Future<void> _initBrightness() async {
    try {
      final platform = ScreenBrightnessPlatform.instance;
      final brightness = await platform.application;
      if (!mounted) return;
      setState(() => _brightness = brightness);
      _brightnessSubscription = platform.onApplicationScreenBrightnessChanged
          .listen((value) {
            if (mounted) setState(() => _brightness = value);
          });
    } catch (_) {}
  }

  Future<void> _resetBrightness() async {
    try {
      await ScreenBrightnessPlatform.instance
          .resetApplicationScreenBrightness();
    } catch (_) {}
  }

  // Controls visibility

  void _onVideoBackendChanged() {
    final hasError = _controller.videoBackend.value is AsyncError;
    if (hasError == _hasError || !mounted) return;

    setState(() => _hasError = hasError);
    if (hasError) {
      // Gesture layer is removed, so its end callbacks will never fire.
      _onLongPressEnd();
      _dragStartX = null;
      _swipeSeek = null;
      _showControls();
    } else {
      _scheduleHide();
    }
  }

  void _toggleControls() =>
      _controlsVisible ? _hideControls() : _showControls();

  void _showControls() {
    setState(() {
      _controlsMounted = true;
      _controlsVisible = true;
    });
    _controller.subtitlePaddings.value = const EdgeInsets.only(
      bottom: _subtitleShift,
    );
    _scheduleHide();
  }

  void _hideControls() {
    _hideTimer?.cancel();
    if (!mounted) return;
    setState(() => _controlsVisible = false);
    _controller.subtitlePaddings.value = EdgeInsets.zero;
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_hasError) return;
    _hideTimer = Timer(_hideDelay, _hideControls);
  }

  void _onControlsFadeEnd() {
    if (!_controlsVisible) {
      setState(() => _controlsMounted = false);
    }
  }

  // Double tap seek

  void _onDoubleTap(double width) {
    final x = _doubleTapPosition?.dx;
    if (x == null) return;

    if (x < width / 3) {
      _tapSeek(_SeekDirection.backward);
    } else if (x > width * 2 / 3) {
      _tapSeek(_SeekDirection.forward);
    }
  }

  void _tapSeek(_SeekDirection direction) {
    if (_tapSeekDirection != direction) {
      _commitTapSeek();
    }
    _tapSeekTimer?.cancel();
    setState(() {
      _tapSeekDirection = direction;
      _tapSeekAmount += _tapSeekStep;
    });
    _tapSeekTimer = Timer(_tapSeekCommitDelay, _commitTapSeek);
  }

  void _commitTapSeek() {
    _tapSeekTimer?.cancel();
    switch (_tapSeekDirection) {
      case _SeekDirection.forward:
        _controller.seekForward(_tapSeekAmount);
      case _SeekDirection.backward:
        _controller.seekBackward(_tapSeekAmount);
      case null:
        return;
    }
    setState(() {
      _tapSeekDirection = null;
      _tapSeekAmount = Duration.zero;
    });
  }

  // Horizontal swipe seek

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final startX = _dragStartX;
    if (startX == null) return;

    final state = _controller.videoBackendState;
    final duration = state.duration.inSeconds;
    final position = state.position.inSeconds;

    final offset =
        ((details.localPosition.dx - startX) *
                duration /
                _horizontalSensitivity)
            .round();
    final target = (position + offset).clamp(0, duration);

    setState(() => _swipeSeek = Duration(seconds: target - position));
  }

  void _onHorizontalDragEnd() {
    final seek = _swipeSeek;
    if (seek != null && seek != Duration.zero) {
      _controller.seekForward(seek);
    }
    setState(() {
      _dragStartX = null;
      _swipeSeek = null;
    });
  }

  // Vertical swipe: brightness (left half) / volume (right half)

  void _onVerticalDragUpdate(DragUpdateDetails details, double width) {
    final delta = -details.delta.dy / _verticalSensitivity;
    if (details.localPosition.dx <= width / 2) {
      _setBrightness((_brightness + delta).clamp(0.0, 1.0));
    } else {
      _setVolume((_volume + delta).clamp(0.0, 1.0));
    }
  }

  void _setVolume(double value) {
    _volumeController.setVolume(value).catchError((_) {});
    setState(() => _volume = value);
    _flashIndicator(_Indicator.volume);
  }

  void _setBrightness(double value) {
    ScreenBrightnessPlatform.instance
        .setApplicationScreenBrightness(value)
        .catchError((_) {});
    setState(() => _brightness = value);
    _flashIndicator(_Indicator.brightness);
  }

  void _flashIndicator(_Indicator indicator) {
    _indicatorTimer?.cancel();
    if (_indicator != indicator) {
      setState(() => _indicator = indicator);
    }
    _indicatorTimer = Timer(_indicatorHideDelay, () {
      if (mounted) setState(() => _indicator = null);
    });
  }

  // Long press speed-up

  void _onLongPressStart() {
    final rate = _controller.videoBackendState.playbackSpeed;
    _controller.setRate(rate * _speedUpFactor);
    setState(() => _rateBeforeSpeedUp = rate);
  }

  void _onLongPressEnd() {
    final rate = _rateBeforeSpeedUp;
    if (rate == null) return;
    _controller.setRate(rate);
    setState(() => _rateBeforeSpeedUp = null);
  }

  @override
  Widget build(BuildContext context) {
    final seekPreview = _seekPreview;
    final swipeSeek = _swipeSeek;
    final tapSeekDirection = _tapSeekDirection;

    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Colors.black,
        hoverColor: Colors.black,
        splashColor: Colors.black,
        highlightColor: Colors.black,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Focus(
          autofocus: true,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (!_hasError)
                  Positioned.fill(
                    left: _edgeInset,
                    top: _edgeInset,
                    right: _edgeInset,
                    bottom: _edgeInset + _subtitleShift,
                    child: _buildGestureLayer(),
                  ),
                if (_controlsMounted)
                  Positioned.fill(
                    // Hidden (or fading out) controls must not receive taps.
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: AnimatedOpacity(
                        opacity: _controlsVisible ? 1.0 : 0.0,
                        curve: Curves.easeInOut,
                        duration: _fadeDuration,
                        onEnd: _onControlsFadeEnd,
                        child: _ControlsOverlay(
                          seekPreview: seekPreview,
                          showCenterButtons: !_hasError,
                          onSeekStart: () => _hideTimer?.cancel(),
                          onSeekEnd: _scheduleHide,
                        ),
                      ),
                    ),
                  )
                else if (seekPreview != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(child: _SeekBar(preview: seekPreview)),
                  ),
                if (tapSeekDirection != null)
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: tapSeekDirection == _SeekDirection.backward
                              ? _TapSeekZone(
                                  direction: _SeekDirection.backward,
                                  amount: _tapSeekAmount,
                                  onTap: () =>
                                      _tapSeek(_SeekDirection.backward),
                                )
                              : const SizedBox(),
                        ),
                        const Spacer(),
                        Expanded(
                          child: tapSeekDirection == _SeekDirection.forward
                              ? _TapSeekZone(
                                  direction: _SeekDirection.forward,
                                  amount: _tapSeekAmount,
                                  onTap: () => _tapSeek(_SeekDirection.forward),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                const IgnorePointer(child: BufferingIndicator()),
                _Pill(
                  visible: _indicator == _Indicator.volume,
                  leading: _volume == 0.0
                      ? Icons.volume_off
                      : _volume < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
                  text: '${(_volume * 100.0).round()}%',
                ),
                _Pill(
                  visible: _indicator == _Indicator.brightness,
                  leading: _brightness < 1.0 / 3.0
                      ? Icons.brightness_low
                      : _brightness < 2.0 / 3.0
                      ? Icons.brightness_medium
                      : Icons.brightness_high,
                  text: '${(_brightness * 100.0).round()}%',
                ),
                _Pill(
                  visible: swipeSeek != null,
                  text: swipeSeek == null
                      ? ''
                      : '${swipeSeek.isNegative ? '-' : '+'} ${formatDuration(swipeSeek.abs())}',
                ),
                Positioned(
                  top:
                      MediaQuery.paddingOf(context).top +
                      _topBarMargin.vertical +
                      _buttonBarHeight +
                      16.0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _Pill(
                      visible: _rateBeforeSpeedUp != null,
                      height: 48.0,
                      text: '${_speedUpFactor.toStringAsFixed(1)}x',
                      trailing: Icons.fast_forward,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGestureLayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          onDoubleTapDown: (details) =>
              _doubleTapPosition = details.localPosition,
          onDoubleTap: () => _onDoubleTap(width),
          onLongPressStart: (_) => _onLongPressStart(),
          onLongPressEnd: (_) => _onLongPressEnd(),
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: (_) => _onHorizontalDragEnd(),
          onHorizontalDragCancel: _onHorizontalDragEnd,
          onVerticalDragUpdate: (details) =>
              _onVerticalDragUpdate(details, width),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final Duration? seekPreview;
  final bool showCenterButtons;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;

  const _ControlsOverlay({
    required this.seekPreview,
    required this.showCenterButtons,
    required this.onSeekStart,
    required this.onSeekEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_scrimColor, _transparent],
            ),
          ),
          child: Padding(
            padding: _topBarMargin.copyWith(
              bottom: _topBarMargin.bottom + _scrimFade,
            ),
            child: const SizedBox(
              height: _buttonBarHeight,
              child: Row(
                children: [
                  ExitButton(),
                  SizedBox(width: 8),
                  MediaTitle(),
                  Spacer(),
                  PlayerPlaylistButton(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: showCenterButtons
              ? const Row(
                  children: [
                    Spacer(flex: 2),
                    _CircleBackdrop(child: SkipPrevButton(iconSize: 36.0)),
                    Spacer(),
                    _CircleBackdrop(child: PlayOrPauseButton(iconSize: 48.0)),
                    Spacer(),
                    _CircleBackdrop(child: SkipNextButton(iconSize: 36.0)),
                    Spacer(flex: 2),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [_scrimColor, _transparent],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: _scrimFade),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _SeekBar(
                  preview: seekPreview,
                  onSeekStart: onSeekStart,
                  onSeekEnd: onSeekEnd,
                ),
                Container(
                  height: _buttonBarHeight,
                  margin: _bottomBarMargin,
                  child: const Row(
                    children: [
                      _PositionIndicator(),
                      Spacer(),
                      TrackSelector(),
                      SourceSelector(),
                      PlayerSettingsButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleBackdrop extends StatelessWidget {
  final Widget child;

  const _CircleBackdrop({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _scrimColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _PlaybackStateBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, VideoBackendState state) builder;

  const _PlaybackStateBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    final controller = videoContentController(context);
    return StreamBuilder<VideoBackendState>(
      stream: controller.videoBackendStateStream,
      initialData: controller.videoBackendState,
      builder: (context, snapshot) =>
          builder(context, snapshot.data ?? controller.videoBackendState),
    );
  }
}

class _PositionIndicator extends StatelessWidget {
  const _PositionIndicator();

  @override
  Widget build(BuildContext context) {
    return _PlaybackStateBuilder(
      builder: (context, state) => Text(
        '${formatDuration(state.position)} / ${formatDuration(state.duration)}',
        style: const TextStyle(height: 1.0, fontSize: 12.0, color: _white),
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  /// Offset added to the current position to preview a pending seek.
  final Duration? preview;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;

  const _SeekBar({this.preview, this.onSeekStart, this.onSeekEnd});

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  static const _thumbSize = 12.8;
  static const _barHeight = 12.8;
  static const _hitHeight = 36.0;
  static const _barColor = Color(0x3DFFFFFF);

  // Non-null while the user is dragging the bar.
  double? _dragValue;

  double _fraction(Duration value, Duration total) {
    if (total.inMilliseconds <= 0) return 0.0;
    return (value.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  void _onDown(double x, double width) {
    widget.onSeekStart?.call();
    setState(() => _dragValue = (x / width).clamp(0.0, 1.0));
  }

  void _onMove(double x, double width, Duration duration) {
    final value = (x / width).clamp(0.0, 1.0);
    setState(() => _dragValue = value);
    videoContentController(context).seekTo(duration * value);
  }

  void _onUp(Duration duration) {
    final value = _dragValue;
    if (value != null) {
      videoContentController(context).seekTo(duration * value);
    }
    setState(() => _dragValue = null);
    widget.onSeekEnd?.call();
  }

  void _onCancel() {
    setState(() => _dragValue = null);
    widget.onSeekEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return _PlaybackStateBuilder(
          builder: (context, state) {
            final position = state.position + (widget.preview ?? Duration.zero);
            final value = _dragValue ?? _fraction(position, state.duration);
            final buffered = _fraction(state.buffered, state.duration);

            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => _onDown(e.localPosition.dx, width),
              onPointerMove: (e) =>
                  _onMove(e.localPosition.dx, width, state.duration),
              onPointerUp: (_) => _onUp(state.duration),
              onPointerCancel: (_) => _onCancel(),
              child: SizedBox(
                width: width,
                height: _hitHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: width,
                      height: _barHeight,
                      color: _barColor,
                    ),
                    Container(
                      width: width * buffered,
                      height: _barHeight,
                      color: _barColor,
                    ),
                    Container(
                      width: width * value,
                      height: _barHeight,
                      color: primary,
                    ),
                    Positioned(
                      left: width * value - _thumbSize / 2,
                      bottom: _barHeight / 2 - _thumbSize / 2,
                      child: Container(
                        width: _thumbSize,
                        height: _thumbSize,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TapSeekZone extends StatelessWidget {
  final _SeekDirection direction;
  final Duration amount;
  final VoidCallback onTap;

  const _TapSeekZone({
    required this.direction,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final forward = direction == _SeekDirection.forward;
    const solid = Color(0x88767676);
    const transparent = Color(0x00767676);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: forward ? [transparent, solid] : [solid, transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        splashColor: const Color(0x44767676),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                forward ? Icons.fast_forward : Icons.fast_rewind,
                size: 24.0,
                color: _white,
              ),
              const SizedBox(height: 8.0),
              Text(
                '${amount.inSeconds} seconds',
                style: const TextStyle(fontSize: 12.0, color: _white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final bool visible;
  final String text;
  final IconData? leading;
  final IconData? trailing;
  final double height;

  const _Pill({
    required this.visible,
    required this.text,
    this.leading,
    this.trailing,
    this.height = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        curve: Curves.easeInOut,
        duration: _fadeDuration,
        child: Container(
          height: height,
          width: 108.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0x88000000),
            borderRadius: BorderRadius.circular(64.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[
                Icon(leading, color: _white, size: 24.0),
                const SizedBox(width: 8.0),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 14.0, color: _white),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8.0),
                Icon(trailing, color: _white, size: 24.0),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
