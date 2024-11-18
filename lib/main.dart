import 'dart:ui';

import 'package:strumok/app_database.dart';
import 'package:strumok/app_init_firebase.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/app_secrets.dart';
import 'package:strumok/collection/collection_screen.dart';
import 'package:strumok/content/content_details_screen.dart';
import 'package:strumok/content/manga/manga_content_screen.dart';
import 'package:strumok/content/video/video_content_screen.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/content_suppliers/ffi_suppliers_bundle_storage.dart';
import 'package:strumok/home/home_screen.dart';
import 'package:strumok/layouts/navigation_data.dart';
import 'package:strumok/search/search_screen.dart';
import 'package:strumok/settings/settings_screen.dart';
import 'package:strumok/settings/suppliers/suppliers_screen.dart';
import 'package:strumok/utils/android_tv.dart';
import 'package:strumok/utils/error_observer.dart';
import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktopDevice()) {
    await windowManager.ensureInitialized();
  }

  // init media kit
  MediaKit.ensureInitialized();

  await AppSecrets.init();
  await AppDatabase.init();
  await AppPreferences.init();
  await AndroidTVDetector.detect();

  // init firebase
  await AppInitFirebase.init();

  // load suppliers
  await FFISuppliersBundleStorage.instance.setup();
  await ContentSuppliers.instance.load();

  // start ui
  runApp(ProviderScope(
    observers: [ErrorProviderObserver()],
    child: const MainApp(),
  ));
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
        routerConfig: GoRouter(
          navigatorKey: rootNavigatorKey,
          // initialLocation: "/search",
          // initialLocation: "/collection",
          // initialLocation: "/settings",
          // initialLocation: "/settings/suppliers",
          // initialLocation:
          //     "/manga/MangaDex/77488c29-1c01-43d9-803e-e132fbb0f9b6",
          // initialLocation:
          //     "/video/AniTube/2710-cey-prekrasniy-svt-blagoslovenniy-bogom-2-sezon",
          // initialLocation: "/content/Eneyida/9339-sogun-shogun",
          routes: [
            GoRoute(
              path: NavigationRoute.home.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: NavigationRoute.search.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SearchScreen(),
              ),
            ),
            GoRoute(
              path: NavigationRoute.collection.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CollectionScreen(),
              ),
            ),
            GoRoute(
              path: NavigationRoute.settings.path,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
            GoRoute(
              path: "/settings/suppliers",
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SuppliersSettingsScreen(),
              ),
            ),
            GoRoute(
              path: "/content/:supplier/:id",
              pageBuilder: (context, state) => NoTransitionPage(
                child: ContentDetailsScreen(
                  supplier: state.pathParameters["supplier"]!,
                  id: state.pathParameters["id"]!,
                ),
              ),
            ),
            GoRoute(
              path: "/video/:supplier/:id",
              pageBuilder: (context, state) => NoTransitionPage(
                child: VideoContentScreen(
                  supplier: state.pathParameters["supplier"]!,
                  id: state.pathParameters["id"]!,
                ),
              ),
            ),
            GoRoute(
              path: "/manga/:supplier/:id",
              pageBuilder: (context, state) => NoTransitionPage(
                child: MangaContentScreen(
                  supplier: state.pathParameters["supplier"]!,
                  id: state.pathParameters["id"]!,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
