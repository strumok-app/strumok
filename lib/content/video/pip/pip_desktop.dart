import 'package:flutter/material.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/content/video/pip/pip.dart';
import 'package:window_manager/window_manager.dart';

class DesktopPip extends Pip {
  static const _pipLongSide = 576.0;
  static const _settleDelay = Duration(milliseconds: 100);

  bool _enabled = false;
  double _aspectRatio = 16 / 9;

  Rect? _restoreBounds;
  bool _restoreMaximized = false;
  bool _restoreFullScreen = false;

  // Window transitions are async and must not interleave.
  Future<void> _transitions = Future.value();

  @override
  bool get isSupported => true;

  Future<void> _enqueue(Future<void> Function() transition) {
    return _transitions = _transitions.then((_) async {
      try {
        await transition();
      } catch (e, stackTrace) {
        logger.warning('PIP window transition failed', e, stackTrace);
      }
    });
  }

  @override
  Future<void> enable() async {
    _enabled = true;
  }

  @override
  Future<void> disable() async {
    _enabled = false;
    await exit();
  }

  @override
  Future<void> updatePlayback(PipPlaybackState state) async {
    if (state.aspectRatio.isFinite && state.aspectRatio > 0) {
      _aspectRatio = state.aspectRatio;
    }
  }

  Size _pipSize() {
    final ratio = _aspectRatio.clamp(9 / 16, 21 / 9);
    return ratio >= 1
        ? Size(_pipLongSide, _pipLongSide / ratio)
        : Size(_pipLongSide * ratio, _pipLongSide);
  }

  @override
  Future<void> enter() {
    if (!_enabled || isActive.value) return _transitions;
    active = true;

    return _enqueue(() async {
      _restoreFullScreen = await windowManager.isFullScreen();
      if (_restoreFullScreen) {
        await windowManager.setFullScreen(false);
        await Future.delayed(_settleDelay);
      }
      _restoreMaximized = await windowManager.isMaximized();
      if (_restoreMaximized) {
        await windowManager.unmaximize();
        await Future.delayed(_settleDelay);
      }
      _restoreBounds = await windowManager.getBounds();

      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await Future.delayed(_settleDelay);
      await windowManager.setSize(_pipSize());
      await windowManager.setAlwaysOnTop(true);
      await Future.delayed(_settleDelay);
      await windowManager.setAlignment(Alignment.bottomRight);
    });
  }

  @override
  Future<void> exit() {
    if (!isActive.value) return _transitions;
    active = false;

    return _enqueue(() async {
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await Future.delayed(_settleDelay);

      final bounds = _restoreBounds;
      if (bounds != null) {
        await windowManager.setBounds(bounds);
      } else {
        await windowManager.setSize(const Size(1280, 720));
        await windowManager.setAlignment(Alignment.center);
      }

      if (_restoreMaximized) {
        await Future.delayed(_settleDelay);
        await windowManager.maximize();
      }
      if (_restoreFullScreen) {
        await Future.delayed(_settleDelay);
        await windowManager.setFullScreen(true);
      }
    });
  }

  @override
  Future<void> closeApp() async {
    await windowManager.close();
  }
}
