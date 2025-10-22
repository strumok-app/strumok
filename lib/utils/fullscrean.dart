import 'package:window_manager/window_manager.dart';

void toggleFullscreen() async {
  final fullscrean = await windowManager.isFullScreen();
  await windowManager.setFullScreen(!fullscrean);
}

void enterFullscreen() {
  windowManager.setFullScreen(true);
}

void exitFullscreen() {
  windowManager.setFullScreen(false);
}
