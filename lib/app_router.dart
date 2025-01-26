import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.custom();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: CollectionRoute.page),
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: ContentDetailsRoute.page),
        AutoRoute(page: VideoContentRoute.page),
        AutoRoute(page: MangaContentRoute.page),
        AutoRoute(page: SuppliersSettingsRoute.page),
        AutoRoute(page: DownloadsRoute.page),
      ];
}
