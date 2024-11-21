import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class AndroidTVDetector {
  AndroidTVDetector._();

  static bool _isTV = false;

  static bool get isTV => _isTV;

  static Future<bool> detect() async {
    if (!Platform.isAndroid) {
      _isTV = false;
      return _isTV;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Check for the presence of features typical of Android TV
    _isTV = androidInfo.systemFeatures.contains('android.software.leanback') ||
        androidInfo.systemFeatures.contains('android.software.live_tv');

    return _isTV;
  }
}
