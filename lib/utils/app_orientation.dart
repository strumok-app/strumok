import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:strumok/utils/tv.dart';

abstract final class AppOrientation {
  static const _landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
  static const _portrait = [DeviceOrientation.portraitUp];

  static int _fullscreenVideoCount = 0;

  static bool get isMobile =>
      !TVDetector.isTV && (Platform.isAndroid || Platform.isIOS);

  static bool get isPhone {
    if (!isMobile) {
      return false;
    }

    final dispatcher = PlatformDispatcher.instance;
    Size? size;
    double? pixelRatio;

    if (dispatcher.displays.isNotEmpty) {
      final display = dispatcher.displays.first;
      size = display.size;
      pixelRatio = display.devicePixelRatio;
    }

    if (size == null || size.isEmpty) {
      final view = dispatcher.implicitView;
      size = view?.physicalSize;
      pixelRatio = view?.devicePixelRatio;
    }

    if (size == null || size.isEmpty || pixelRatio == null) {
      return true;
    }

    return size.shortestSide / pixelRatio < 600;
  }

  /// Phones are locked to portrait outside fullscreen video, other devices
  /// follow the system settings.
  static Future<void> applyDefault() async {
    if (!isMobile) {
      return;
    }

    await SystemChrome.setPreferredOrientations(isPhone ? _portrait : const []);
  }

  static Future<void> enterFullscreenVideo() async {
    _fullscreenVideoCount++;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(_landscape);
  }

  static Future<void> exitFullscreenVideo() async {
    if (_fullscreenVideoCount > 0) {
      _fullscreenVideoCount--;
    }

    if (_fullscreenVideoCount > 0) {
      return;
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await applyDefault();
  }

  /// Completes once [view] is laid out in portrait or after [timeout].
  ///
  /// Rotation latency varies a lot on some devices (over 1s on OneUI after a
  /// system back gesture), so the timeout is only a safety net.
  static Future<void> waitForPortrait(
    FlutterView view, {
    Duration timeout = const Duration(seconds: 3),
  }) {
    bool isPortrait() => view.physicalSize.height > view.physicalSize.width;

    if (isPortrait()) {
      return Future.value();
    }

    final completer = Completer<void>();
    final observer = _MetricsObserver(() {
      if (isPortrait() && !completer.isCompleted) {
        completer.complete();
      }
    });

    WidgetsBinding.instance.addObserver(observer);

    return completer.future
        .timeout(timeout, onTimeout: () {})
        .whenComplete(() => WidgetsBinding.instance.removeObserver(observer));
  }
}

class _MetricsObserver with WidgetsBindingObserver {
  final VoidCallback onChange;

  _MetricsObserver(this.onChange);

  @override
  void didChangeMetrics() => onChange();
}
