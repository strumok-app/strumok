import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_rust/rust/frb_generated.dart';
import 'package:content_suppliers_rust/rust/frb_generated.io.dart';
import 'package:content_suppliers_rust/rust/models.dart' as models;
import 'package:flutter/widgets.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

const compatibleApiVersoin = 3;

// ignore_for_file: invalid_use_of_internal_member
class RustContentSuppliersBundle implements ContentSupplierBundle {
  final String? directory;
  final String libName;
  _CustomRustLib? _lib;

  RustContentSuppliersBundle({required this.directory, required this.libName});

  @override
  Future<void> load() async {
    if (_lib == null) {
      _lib = _CustomRustLib(directory: directory, libName: libName);

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

    return api
        .crateApiAvalaibleSuppliers()
        .map((supplier) => _RustContentSupplier(name: supplier, api: api))
        .toList();
  }

  static bool isCompatible(int apiVersion) {
    return compatibleApiVersoin == apiVersion;
  }
}

class _RustContentSupplier implements ContentSupplier {
  final RustLibApi _api;
  Set<ContentType>? _supportedTypes;
  Set<ContentLanguage>? _supportedLanguage;

  @override
  final String name;

  _RustContentSupplier({required this.name, required RustLibApi api})
    : _api = api;

  @override
  Set<String> get channels {
    return _api.crateApiGetChannels(supplier: name).toSet();
  }

  @override
  Set<String> get defaultChannels {
    return _api.crateApiGetDefaultChannels(supplier: name).toSet();
  }

  @override
  Future<ContentDetails?> detailsById(
    String id,
    Set<ContentLanguage> langs,
  ) async {
    try {
      final langsCodes = langs.map((lang) => lang.name).toList();

      final result = await _api.crateApiGetContentDetails(
        supplier: name,
        id: id,
        langs: langsCodes,
      );

      if (result == null) {
        return null;
      }

      return _RustContentDetails.fromRust(id, name, langsCodes, result, _api);
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

      return results
          .map((info) => ContentSearchResultExt.fromRust(name, info))
          .toList();
    } catch (e) {
      throw ContentSuppliersException(
        "FFI LoadChannel Failed [supplier=$name channel=$channel page=$page] error: $e",
      );
    }
  }

  @override
  Future<List<ContentInfo>> search(String query, {int page = 0}) async {
    try {
      final results = await _api.crateApiSearch(
        supplier: name,
        query: query,
        page: page,
      );

      return results
          .map((info) => ContentSearchResultExt.fromRust(name, info))
          .toList();
    } catch (e) {
      throw ContentSuppliersException(
        "FFI Search Failed [supplier=$name query=$query] error: $e",
      );
    }
  }

  @override
  Set<ContentLanguage> get supportedLanguages {
    _supportedLanguage ??= _api
        .crateApiGetSupportedLanguages(supplier: name)
        .map(
          (lang) =>
              ContentLanguage.values.firstWhereOrNull((v) => v.name == lang),
        )
        .nonNulls
        .toSet();

    return _supportedLanguage!;
  }

  @override
  Set<ContentType> get supportedTypes {
    return _supportedTypes ??= _api
        .crateApiGetSupportedTypes(supplier: name)
        .map(
          (type) =>
              ContentType.values.firstWhereOrNull((v) => v.name == type.name),
        )
        .nonNulls
        .toSet();
  }
}

extension ContentSearchResultExt on ContentSearchResult {
  static ContentSearchResult fromRust(
    String supplier,
    models.ContentInfo info,
  ) {
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
  final List<String> langs;
  final List<String> _params;
  @override
  final MediaType mediaType;
  Iterable<ContentMediaItem>? _mediaItems;

  _RustContentDetails._({
    required super.id,
    required super.supplier,
    required this.langs,
    required super.title,
    required super.secondaryTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.mediaType,
    Iterable<ContentMediaItem>? mediaItems,
    required RustLibApi api,
    required List<String> params,
  }) : _api = api,
       _mediaItems = mediaItems,
       _params = params;

  factory _RustContentDetails.fromRust(
    String id,
    String supplier,
    List<String> langs,
    models.ContentDetails result,
    RustLibApi api,
  ) {
    return _RustContentDetails._(
      id: id,
      supplier: supplier,
      langs: langs,
      mediaType: MediaType.values.firstWhere(
        (v) => v.name == result.mediaType.name,
        orElse: () => MediaType.video,
      ),
      title: result.title,
      secondaryTitle: result.originalTitle,
      image: result.image,
      description: result.description,
      additionalInfo: result.additionalInfo,
      similar: result.similar
          .map((info) => ContentSearchResultExt.fromRust(supplier, info))
          .toList(),
      mediaItems: result.mediaItems?.mapIndexed(
        (idx, item) =>
            _RustMediaItem.fromRust(id, supplier, idx, langs, item, api),
      ),
      params: result.params,
      api: api,
    );
  }

  @override
  FutureOr<Iterable<ContentMediaItem>> get mediaItems async {
    try {
      return _mediaItems ??=
          (await _api.crateApiLoadMediaItems(
            supplier: supplier,
            id: id,
            langs: langs,
            params: _params,
          )).mapIndexed(
            (idx, item) =>
                _RustMediaItem.fromRust(id, supplier, idx, langs, item, _api),
          );
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
  final List<String> langs;
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
    required this.langs,
    required this.number,
    required this.title,
    required this.section,
    required this.image,
    required List<ContentMediaItemSource>? sources,
    required List<String> params,
    required RustLibApi api,
  }) : _sources = sources,
       _params = params,
       _api = api;

  factory _RustMediaItem.fromRust(
    String id,
    String supplier,
    int number,
    List<String> langs,
    models.ContentMediaItem item,
    RustLibApi api,
  ) {
    return _RustMediaItem._(
      id: id,
      supplier: supplier,
      langs: langs,
      number: number,
      title: item.title,
      section: item.section,
      image: item.image,
      sources: item.sources
          ?.map((item) => mapMediaItemSource(id, supplier, item, api))
          .toList(),
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
        langs: langs,
        params: _params,
      )).map((item) => mapMediaItemSource(id, supplier, item, _api)).toList();
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
  ) => switch (item) {
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
    models.ContentMediaItemSource_Manga() => _RustMangaMediaItemSource.fromRust(
      id,
      supplier,
      item,
      api,
    ),
  };
}

class _RustMangaMediaItemSource implements MangaMediaItemSource {
  final String id;
  final String supplier;
  @override
  final String description;
  final Map<String, String>? headers;

  List<String>? _pages;
  List<ImageProvider<Object>>? _images;
  final RustLibApi _api;
  final List<String> _params;

  _RustMangaMediaItemSource._({
    required this.id,
    required this.supplier,
    required this.description,
    required List<String>? pages,
    required RustLibApi api,
    required List<String> params,
    this.headers,
  }) : _pages = pages,
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
      description: item.description,
      headers: item.headers,
      pages: item.pages,
      params: item.params,
      api: api,
    );
  }

  @override
  FileKind get kind => FileKind.manga;

  @override
  Future<List<String>> get pages async {
    return _pages ??= (await _api.crateApiLoadMangaPages(
      supplier: supplier,
      id: id,
      params: _params,
    ));
  }

  @override
  Future<List<ImageProvider<Object>>> get images async {
    return _images ??= (await pages)
        .map((link) => CachedNetworkImageProvider(link, headers: headers))
        .toList();
  }
}

class _CustomRustLib
    extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  final String? directory;
  final String libName;
  ExternalLibrary? externalLibrary;

  _CustomRustLib({required this.directory, required this.libName});

  Future<void> init() async {
    externalLibrary = await _loadExternalLibrary(
      defaultExternalLibraryLoaderConfig,
    );

    return initImpl(api: null, handler: null, externalLibrary: externalLibrary);
  }

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.crateApiInitApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      ExternalLibraryLoaderConfig(
        stem: libName,
        ioDirectory: directory,
        webPrefix: null,
      );

  @override
  String get codegenVersion => RustLib.instance.codegenVersion;

  @override
  int get rustContentHash => RustLib.instance.rustContentHash;

  void unload() {
    externalLibrary?.ffiDynamicLibrary.close();
  }
}

FutureOr<ExternalLibrary> _loadExternalLibrary(
  ExternalLibraryLoaderConfig config,
) async {
  final ioDirectory = config.ioDirectory!;

  final stem = config.stem;

  ExternalLibrary tryLoad(String name) {
    final filePath = ioDirectory + Platform.pathSeparator + name;
    if (!File(filePath).existsSync()) {
      throw ContentSuppliersException(
        "Rust Suppliers lib not found in path: $filePath",
      );
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

  throw Exception(
    'loadExternalLibrary failed: Unknown platform=${Platform.operatingSystem}',
  );
}
