import 'dart:ui';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:strumok/app_database.dart';
import 'package:strumok/app_init_firebase.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/app_router.dart';
import 'package:strumok/app_secrets.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/content_suppliers/ffi_suppliers_bundle_storage.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/upgrade/version_guard.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/error_observer.dart';
import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  SentryFlutter.init(
    (options) {
      options
        ..dsn = const String.fromEnvironment("SENTRY_DSN")
        ..tracesSampleRate = 1.0;
    },
    appRunner: appRunner,
  );
}

void appRunner() async {
  await AppSecrets.init();

  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktopDevice()) {
    await windowManager.ensureInitialized();
  }

  // init media kit
  MediaKit.ensureInitialized();

  await AppDatabase.init();
  await AppPreferences.init();
  await TVDetector.detect();

  // init firebase
  await AppInitFirebase.init();

  // load suppliers
  await FFISuppliersBundleStorage.instance.setup();
  await ContentSuppliers.instance.load();

  // start ui
  runApp(ProviderScope(
    observers: [ErrorProviderObserver()],
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  final _appRouter = AppRouter();

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad
        }),
        routerConfig: _appRouter.config(),
        builder: (context, child) => AppTheme(
          child: VersionGuard(child: child!),
        ),
      ),
    );
  }
}
