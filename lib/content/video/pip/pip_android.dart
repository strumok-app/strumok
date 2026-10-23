import 'package:flutter/services.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/content/video/pip/pip.dart';

class AndroidPip extends Pip {
  static const _channel = MethodChannel('strumok/pip');

  bool _supported = false;

  @override
  bool get isSupported => _supported;

  @override
  Future<void> init() async {
    _channel.setMethodCallHandler(_handleCall);
    _supported = await _invoke<bool>('isSupported') ?? false;
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'onPipModeChanged':
        active = call.arguments['active'] == true;
      case 'onAction':
        final action = PipAction.values.asNameMap()[call.arguments['action']];
        if (action != null) {
          emitAction(action);
        }
    }
  }

  Future<T?> _invoke<T>(String method, [Map<String, dynamic>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e, stackTrace) {
      logger.warning('PIP call $method failed', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> enable({bool autoEnter = false}) async {
    if (!_supported) return;
    await _invoke('enable', {'autoEnter': autoEnter});
  }

  @override
  Future<void> disable() async {
    if (!_supported) return;
    await _invoke('disable');
  }

  @override
  Future<void> updatePlayback(PipPlaybackState state) async {
    if (!_supported) return;
    await _invoke('update', {
      'isPlaying': state.isPlaying,
      'hasPrev': state.hasPrev,
      'hasNext': state.hasNext,
      'showSkipButtons': state.showSkipButtons,
      'aspectRatio': state.aspectRatio,
    });
  }

  @override
  Future<void> enter() async {
    if (!_supported) return;
    await _invoke('enter');
  }

  @override
  Future<void> exit() async {
    if (!_supported) return;
    await _invoke('exit');
  }

  @override
  Future<void> closeApp() async {
    await _invoke('closeApp');
  }
}
