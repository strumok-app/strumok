import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:strumok/app_database.dart';
import 'package:strumok/app_init_firebase.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/app_router.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/content_suppliers/ffi_suppliers_bundle_storage.dart';
import 'package:strumok/layouts/app_theme.dart';
import 'package:strumok/layouts/version_guard.dart';
import 'package:strumok/download/offline_storage.dart';
import 'package:strumok/video_player/media_kit.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/error_observer.dart';
import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  if (kDebugMode) {
    appRunner();
  } else {
    const sentryDns = String.fromEnvironment("SENTRY_DNS");
    await SentryFlutter.init((options) {
      options.tracesSampleRate = 1.0;
      options.dsn = sentryDns;
    }, appRunner: appRunner);
  }
}

void appRunner() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktopDevice()) {
    await windowManager.ensureInitialized();
  }

  MediaKit.ensureInitialized();
  MediaKitVideoPlayer.registerWith();

  await AppDatabase().init();
  await AppPreferences.init();
  await TVDetector.detect();

  // init firebase
  await AppInitFirebase().init();

  // Downloaded files
  await OfflineStorage().init();
  // load suppliers
  await FFISuppliersBundleStorage().init();
  await ContentSuppliers().load();

  // start ui
  runApp(ProviderScope(observers: [ErrorProviderObserver()], child: MainApp()));
}

class MainApp extends ConsumerWidget {
  final _appRouter = AppRouter();

  MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLang = ref.watch(userLanguageSettingProvider);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp.router(
        locale: Locale(userLang),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        ),
        routerConfig: _appRouter.config(
          navigatorObservers: () => [SentryNavigatorObserver()],
        ),
        builder: (context, child) =>
            AppTheme(child: VersionGuard(child: child!)),
      ),
    );
  }
}
