import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class TVDetector {
  TVDetector._();

  static bool _isTV = false;

  static bool get isTV => _isTV;

  static Future<bool> detect() async {
    final forceTvMode = const bool.fromEnvironment("FORCE_TV_MODE");
    if (forceTvMode) {
      _isTV = true;
      return _isTV;
    }

    if (!Platform.isAndroid) {
      _isTV = false;
      return _isTV;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Check for the presence of features typical of Android TV
    _isTV =
        androidInfo.systemFeatures.contains('android.software.leanback') ||
        androidInfo.systemFeatures.contains('android.software.live_tv');

    return _isTV;
  }
}
