// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:strumok/collection/collection_screen.dart' as _i1;
import 'package:strumok/content/content_details_screen.dart' as _i2;
import 'package:strumok/content/manga/manga_content_screen.dart' as _i4;
import 'package:strumok/content/video/video_content_screen.dart' as _i8;
import 'package:strumok/home/home_screen.dart' as _i3;
import 'package:strumok/search/search_screen.dart' as _i5;
import 'package:strumok/settings/settings_screen.dart' as _i6;
import 'package:strumok/settings/suppliers/suppliers_screen.dart' as _i7;

/// generated route for
/// [_i1.CollectionScreen]
class CollectionRoute extends _i9.PageRouteInfo<void> {
  const CollectionRoute({List<_i9.PageRouteInfo>? children})
      : super(
          CollectionRoute.name,
          initialChildren: children,
        );

  static const String name = 'CollectionRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.CollectionScreen();
    },
  );
}

/// generated route for
/// [_i2.ContentDetailsScreen]
class ContentDetailsRoute extends _i9.PageRouteInfo<ContentDetailsRouteArgs> {
  ContentDetailsRoute({
    _i10.Key? key,
    required String supplier,
    required String id,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          ContentDetailsRoute.name,
          args: ContentDetailsRouteArgs(
            key: key,
            supplier: supplier,
            id: id,
          ),
          initialChildren: children,
        );

  static const String name = 'ContentDetailsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentDetailsRouteArgs>();
      return _i2.ContentDetailsScreen(
        key: args.key,
        supplier: args.supplier,
        id: args.id,
      );
    },
  );
}

class ContentDetailsRouteArgs {
  const ContentDetailsRouteArgs({
    this.key,
    required this.supplier,
    required this.id,
  });

  final _i10.Key? key;

  final String supplier;

  final String id;

  @override
  String toString() {
    return 'ContentDetailsRouteArgs{key: $key, supplier: $supplier, id: $id}';
  }
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomeScreen();
    },
  );
}

/// generated route for
/// [_i4.MangaContentScreen]
class MangaContentRoute extends _i9.PageRouteInfo<MangaContentRouteArgs> {
  MangaContentRoute({
    _i10.Key? key,
    required String supplier,
    required String id,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          MangaContentRoute.name,
          args: MangaContentRouteArgs(
            key: key,
            supplier: supplier,
            id: id,
          ),
          initialChildren: children,
        );

  static const String name = 'MangaContentRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MangaContentRouteArgs>();
      return _i4.MangaContentScreen(
        key: args.key,
        supplier: args.supplier,
        id: args.id,
      );
    },
  );
}

class MangaContentRouteArgs {
  const MangaContentRouteArgs({
    this.key,
    required this.supplier,
    required this.id,
  });

  final _i10.Key? key;

  final String supplier;

  final String id;

  @override
  String toString() {
    return 'MangaContentRouteArgs{key: $key, supplier: $supplier, id: $id}';
  }
}

/// generated route for
/// [_i5.SearchScreen]
class SearchRoute extends _i9.PageRouteInfo<void> {
  const SearchRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.SearchScreen();
    },
  );
}

/// generated route for
/// [_i6.SettingsScreen]
class SettingsRoute extends _i9.PageRouteInfo<void> {
  const SettingsRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i7.SuppliersSettingsScreen]
class SuppliersSettingsRoute extends _i9.PageRouteInfo<void> {
  const SuppliersSettingsRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SuppliersSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SuppliersSettingsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.SuppliersSettingsScreen();
    },
  );
}

/// generated route for
/// [_i8.VideoContentScreen]
class VideoContentRoute extends _i9.PageRouteInfo<VideoContentRouteArgs> {
  VideoContentRoute({
    _i10.Key? key,
    required String supplier,
    required String id,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          VideoContentRoute.name,
          args: VideoContentRouteArgs(
            key: key,
            supplier: supplier,
            id: id,
          ),
          initialChildren: children,
        );

  static const String name = 'VideoContentRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoContentRouteArgs>();
      return _i8.VideoContentScreen(
        key: args.key,
        supplier: args.supplier,
        id: args.id,
      );
    },
  );
}

class VideoContentRouteArgs {
  const VideoContentRouteArgs({
    this.key,
    required this.supplier,
    required this.id,
  });

  final _i10.Key? key;

  final String supplier;

  final String id;

  @override
  String toString() {
    return 'VideoContentRouteArgs{key: $key, supplier: $supplier, id: $id}';
  }
}
