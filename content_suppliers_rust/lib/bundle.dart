import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_rust/rust/frb_generated.dart';
import 'package:content_suppliers_rust/rust/frb_generated.io.dart';
import 'package:content_suppliers_rust/rust/models.dart' as models;
import 'package:flutter/widgets.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// ignore_for_file: invalid_use_of_internal_member
class RustContentSuppliersBundle implements ContentSupplierBundle {
  final String? directory;
  final String libName;
  _CustomRustLib? _lib;

  RustContentSuppliersBundle({
    required this.directory,
    required this.libName,
  });

  @override
  Future<void> load() async {
    if (_lib == null) {
      _lib = _CustomRustLib(
        directory: directory,
        libName: libName,
      );

      await _lib!.init();
    }
  }

  @override
  void unload() {
    _lib?.unload();
  }

  @override
  Future<List<ContentSupplier>> get suppliers async {
    if (_lib == null) {
      return [];
    }

    final api = _lib!.api;

    return api.crateApiAvalaibleSuppliers().map((supplier) => _RustContentSupplier(name: supplier, api: api)).toList();
  }
}

class _RustContentSupplier implements ContentSupplier {
  final RustLibApi _api;

  @override
  final String name;

  _RustContentSupplier({required this.name, required RustLibApi api}) : _api = api;

  @override
  Set<String> get channels {
    return _api.crateApiGetChannels(supplier: name).toSet();
  }

  @override
  Set<String> get defaultChannels {
    return _api.crateApiGetDefaultChannels(supplier: name).toSet();
  }

  @override
  Future<ContentDetails?> detailsById(String id) async {
    try {
      final result = await _api.crateApiGetContentDetails(
        supplier: name,
        id: id,
      );

      if (result == null) {
        return null;
      }

      return _RustContentDetails.fromRust(id, name, result, _api);
    } catch (e) {
      throw ContentSuppliersException(
        "FFI GetContentDetails Failed [suppier=$name id=$id] error: $e",
      );
    }
  }

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {int page = 0}) async {
    try {
      final results = await _api.crateApiLoadChannel(
        supplier: name,
        channel: channel,
        page: page,
      );

      return results.map((info) => ContentSearchResultExt.fromRust(name, info)).toList();
    } catch (e) {
      throw ContentSuppliersException(
        "FFI LoadChannel Failed [supplier=$name channel=$channel page=$page] error: $e",
      );
    }
  }

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    try {
      final results = await _api.crateApiSearch(
        supplier: name,
        query: query,
        types: type.map((v) => v.name).toList(),
      );

      return results.map((info) => ContentSearchResultExt.fromRust(name, info)).toList();
    } catch (e) {
      throw ContentSuppliersException(
        "FFI Search Failed [supplier=$name query=$query] error: $e",
      );
    }
  }

  @override
  Set<ContentLanguage> get supportedLanguages {
    return _api
        .crateApiGetSupportedLanguages(supplier: name)
        .map(
          (lang) => ContentLanguage.values.firstWhereOrNull(
            (v) => v.name == lang,
          ),
        )
        .nonNulls
        .toSet();
  }

  @override
  Set<ContentType> get supportedTypes {
    return _api
        .crateApiGetSupportedTypes(supplier: name)
        .map(
          (type) => ContentType.values.firstWhereOrNull(
            (v) => v.name == type.name,
          ),
        )
        .nonNulls
        .toSet();
  }
}

extension ContentSearchResultExt on ContentSearchResult {
  static ContentSearchResult fromRust(String supplier, models.ContentInfo info) {
    return ContentSearchResult(
      id: info.id,
      supplier: supplier,
      image: info.image,
      title: info.title,
      secondaryTitle: info.secondaryTitle,
    );
  }
}

// ignore: must_be_immutable
class _RustContentDetails extends AbstractContentDetails {
  final RustLibApi _api;
  final List<String> _params;
  @override
  final MediaType mediaType;
  Iterable<ContentMediaItem>? _mediaItems;

  _RustContentDetails._({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.mediaType,
    Iterable<ContentMediaItem>? mediaItems,
    required RustLibApi api,
    required List<String> params,
  })  : _api = api,
        _mediaItems = mediaItems,
        _params = params;

  factory _RustContentDetails.fromRust(
    String id,
    String supplier,
    models.ContentDetails result,
    RustLibApi api,
  ) {
    return _RustContentDetails._(
      id: id,
      supplier: supplier,
      mediaType: MediaType.values.firstWhere(
        (v) => v.name == result.mediaType.name,
        orElse: () => MediaType.video,
      ),
      title: result.title,
      originalTitle: result.originalTitle,
      image: result.image,
      description: result.description,
      additionalInfo: result.additionalInfo,
      similar: result.similar.map((info) => ContentSearchResultExt.fromRust(supplier, info)).toList(),
      mediaItems: result.mediaItems?.map(
        (item) => _RustMediaItem.fromRust(id, supplier, item, api),
      ),
      params: result.params,
      api: api,
    );
  }

  @override
  FutureOr<Iterable<ContentMediaItem>> get mediaItems async {
    try {
      return _mediaItems ??= (await _api.crateApiLoadMediaItems(
        supplier: supplier,
        id: id,
        params: _params,
      ))
          .map((item) => _RustMediaItem.fromRust(id, supplier, item, _api));
    } catch (e) {
      throw ContentSuppliersException(
        "FFI LoadMediaItems Failed [supplier=$supplier id=$id params: $_params] error: $e",
      );
    }
  }
}

class _RustMediaItem implements ContentMediaItem {
  final String id;
  final String supplier;
  @override
  final int number;
  @override
  final String title;
  @override
  final String? section;
  @override
  final String? image;
  final RustLibApi _api;
  final List<String> _params;

  List<ContentMediaItemSource>? _sources;

  _RustMediaItem._({
    required this.id,
    required this.supplier,
    required this.number,
    required this.title,
    required this.section,
    required this.image,
    required List<ContentMediaItemSource>? sources,
    required List<String> params,
    required RustLibApi api,
  })  : _sources = sources,
        _params = params,
        _api = api;

  factory _RustMediaItem.fromRust(
    String id,
    String supplier,
    models.ContentMediaItem item,
    RustLibApi api,
  ) {
    return _RustMediaItem._(
      id: id,
      supplier: supplier,
      number: item.number,
      title: item.title,
      section: item.section,
      image: item.image,
      sources: item.sources?.map((item) => mapMediaItemSource(id, supplier, item, api)).toList(),
      params: item.params,
      api: api,
    );
  }

  @override
  FutureOr<List<ContentMediaItemSource>> get sources async {
    try {
      return _sources ??= (await _api.crateApiLoadMediaItemSources(
        supplier: supplier,
        id: id,
        params: _params,
      ))
          .map((item) => mapMediaItemSource(id, supplier, item, _api))
          .toList();
    } catch (e) {
      throw ContentSuppliersException(
        "FFI LoadMediaItemSources Failed [supplier=$supplier id=$id params: $_params] error: $e",
      );
    }
  }

  static ContentMediaItemSource mapMediaItemSource(
    String id,
    String supplier,
    models.ContentMediaItemSource item,
    RustLibApi api,
  ) =>
      switch (item) {
        models.ContentMediaItemSource_Video() => SimpleContentMediaItemSource(
            kind: FileKind.video,
            description: item.description,
            link: Uri.parse(item.link),
            headers: item.headers,
          ),
        models.ContentMediaItemSource_Subtitle() => SimpleContentMediaItemSource(
            kind: FileKind.subtitle,
            description: item.description,
            link: Uri.parse(item.link),
            headers: item.headers,
          ),
        models.ContentMediaItemSource_Manga() => _RustMangaMediaItemSource.fromRust(id, supplier, item, api)
      };
}

class _RustMangaMediaItemSource implements MangaMediaItemSource {
  final String id;
  final String supplier;
  @override
  final String description;
  @override
  final int pageNambers;

  List<ImageProvider>? _pages;
  final RustLibApi _api;
  final List<String> _params;

  _RustMangaMediaItemSource._({
    required this.id,
    required this.supplier,
    required this.description,
    required this.pageNambers,
    required List<ImageProvider>? pages,
    required RustLibApi api,
    required List<String> params,
  })  : _pages = pages,
        _api = api,
        _params = params;

  factory _RustMangaMediaItemSource.fromRust(
    String id,
    String supplier,
    models.ContentMediaItemSource_Manga item,
    RustLibApi api,
  ) {
    return _RustMangaMediaItemSource._(
      id: id,
      supplier: supplier,
      pageNambers: item.pageNumbers,
      description: item.description,
      pages: item.pages?.map((link) => CachedNetworkImageProvider(link)).toList(),
      params: item.params,
      api: api,
    );
  }

  @override
  FileKind get kind => FileKind.manga;

  @override
  Future<List<ImageProvider<Object>>> allPages() async {
    return _pages ??= (await _api.crateApiLoadMangaPages(
      supplier: supplier,
      id: id,
      params: _params,
    ))
        .map((link) => CachedNetworkImageProvider(link))
        .toList();
  }
}

class _CustomRustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  final String? directory;
  final String libName;
  ExternalLibrary? externalLibrary;

  _CustomRustLib({required this.directory, required this.libName});

  Future<void> init() async {
    externalLibrary = await _loadExternalLibrary(defaultExternalLibraryLoaderConfig);

    return initImpl(
      api: null,
      handler: null,
      externalLibrary: externalLibrary,
    );
  }

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor => RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor => RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.crateApiInitApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig => ExternalLibraryLoaderConfig(
        stem: libName,
        ioDirectory: directory,
        webPrefix: null,
      );

  @override
  String get codegenVersion => RustLib.instance.codegenVersion;

  @override
  int get rustContentHash => RustLib.instance.rustContentHash;

  unload() {
    externalLibrary?.ffiDynamicLibrary.close();
  }
}

FutureOr<ExternalLibrary> _loadExternalLibrary(ExternalLibraryLoaderConfig config) async {
  final ioDirectory = config.ioDirectory!;

  final stem = config.stem;

  ExternalLibrary tryLoad(String name) {
    final filePath = ioDirectory + Platform.pathSeparator + name;
    if (!File(filePath).existsSync()) {
      throw ContentSuppliersException("Rust Suppliers lib not found in path: $filePath");
    }

    return ExternalLibrary.open(filePath);
  }

  if (Platform.isWindows) {
    final name = '$stem.dll';
    return tryLoad(name);
  }

  if (Platform.isIOS || Platform.isMacOS) {
    return tryLoad('lib$stem.dylib');
  }

  if (Platform.isLinux || Platform.isAndroid) {
    final name = 'lib$stem.so';
    return tryLoad(name);
  }

  throw Exception('loadExternalLibrary failed: Unknown platform=${Platform.operatingSystem}');
}
