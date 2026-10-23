import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:strumok/content/video/pip/pip_android.dart';
import 'package:strumok/content/video/pip/pip_desktop.dart';
import 'package:strumok/utils/tv.dart';

/// Actions triggered from platform PIP controls (e.g. Android PIP window).
/// [dismissed] - user closed the PIP window, app stays in background.
enum PipAction { playPause, next, prev, dismissed }

class PipPlaybackState extends Equatable {
  final bool isPlaying;
  final bool hasPrev;
  final bool hasNext;
  final bool showSkipButtons;
  final double aspectRatio;

  const PipPlaybackState({
    this.isPlaying = false,
    this.hasPrev = false,
    this.hasNext = false,
    this.showSkipButtons = false,
    this.aspectRatio = 16 / 9,
  });

  @override
  List<Object?> get props => [
    isPlaying,
    hasPrev,
    hasNext,
    showSkipButtons,
    aspectRatio,
  ];
}

/// Platform independent picture-in-picture API.
///
/// PIP is allowed only between [enable] and [disable] calls, so the screen
/// that owns the video decides when PIP is available.
abstract class Pip {
  static final Pip instance = _create();

  static Pip _create() {
    if (TVDetector.isTV) {
      return UnsupportedPip();
    }
    if (Platform.isAndroid) {
      return AndroidPip();
    }
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return DesktopPip();
    }
    return UnsupportedPip();
  }

  final ValueNotifier<bool> _active = ValueNotifier(false);
  final StreamController<PipAction> _actions = StreamController.broadcast();

  ValueListenable<bool> get isActive => _active;

  Stream<PipAction> get actions => _actions.stream;

  @protected
  set active(bool value) => _active.value = value;

  @protected
  void emitAction(PipAction action) => _actions.add(action);

  Future<void> init() async {}

  bool get isSupported;

  /// Allows PIP and automatically enters it when the user leaves the app.
  Future<void> enable();

  /// Disallows PIP and restores the app if PIP is active.
  Future<void> disable();

  Future<void> updatePlayback(PipPlaybackState state);

  Future<void> enter();

  Future<void> exit();

  Future<void> closeApp();
}

class UnsupportedPip extends Pip {
  @override
  bool get isSupported => false;

  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}

  @override
  Future<void> updatePlayback(PipPlaybackState state) async {}

  @override
  Future<void> enter() async {}

  @override
  Future<void> exit() async {}

  @override
  Future<void> closeApp() async {}
}
