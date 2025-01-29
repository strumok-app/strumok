import 'dart:io';

import 'package:strumok/utils/tv.dart';
import 'package:flutter/widgets.dart';

const mobileWidth = 450.0;

bool isMobile(BuildContext context) {
  return MediaQuery.sizeOf(context).width < mobileWidth;
}

bool isMobileDevice() {
  return Platform.isIOS || (Platform.isAndroid && !TVDetector.isTV);
}

bool isDesktopDevice() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}
