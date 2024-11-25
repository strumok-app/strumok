import 'dart:io';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_rust/rust/frb_generated.dart';
import 'package:content_suppliers_rust/rust/frb_generated.io.dart';
import 'package:content_suppliers_rust/rust/models.dart' as models;
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// ignore_for_file: invalid_use_of_internal_member

class RustMediaItem implements ContentMediaItem {
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

  RustMediaItem._({
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

  factory RustMediaItem.fromRust(
    String id,
    String supplier,
    models.ContentMediaItem item,
    RustLibApi api,
  ) {
    return RustMediaItem._(
      id: id,
      supplier: supplier,
      number: item.number,
      title: item.title,
      section: item.section,
      image: item.image,
      sources: item.sources?.map(RustMediaItem.mapMediaItemSource).toList(),
      params: item.params,
      api: api,
    );
  }

  @override
  FutureOr<List<ContentMediaItemSource>> get sources async =>
      _sources ??= (await _api.crateApiLoadMediaItemSources(
        supplier: supplier,
        id: id,
        params: _params,
      ))
          .map(mapMediaItemSource)
          .toList();

  static ContentMediaItemSource mapMediaItemSource(
    models.ContentMediaItemSource item,
  ) =>
      switch (item) {
        models.ContentMediaItemSource_Video() => SimpleContentMediaItemSource(
            kind: FileKind.video,
            description: item.description,
            link: Uri.parse(item.link),
            headers: item.headers,
          ),
        models.ContentMediaItemSource_Subtitle() =>
          SimpleContentMediaItemSource(
            kind: FileKind.subtitle,
            description: item.description,
            link: Uri.parse(item.link),
            headers: item.headers,
          ),
        models.ContentMediaItemSource_Manga() => SimpleMangaMediaItemSource(
            description: item.description,
            pages: item.pages,
          ),
      };
}

// ignore: must_be_immutable
class RustContentDetails extends AbstractContentDetails {
  final RustLibApi _api;
  final List<String> _params;
  @override
  final MediaType mediaType;
  Iterable<ContentMediaItem>? _mediaItems;

  RustContentDetails._({
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

  factory RustContentDetails.fromRust(
    String id,
    String supplier,
    models.ContentDetails result,
    RustLibApi api,
  ) {
    return RustContentDetails._(
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
      similar: result.similar
          .map((info) => ContentSearchResultExt.fromRust(supplier, info))
          .toList(),
      mediaItems: result.mediaItems?.map(
        (item) => RustMediaItem.fromRust(id, supplier, item, api),
      ),
      params: result.params,
      api: api,
    );
  }

  @override
  FutureOr<Iterable<ContentMediaItem>> get mediaItems async =>
      _mediaItems ??= (await _api.crateApiLoadMediaItems(
        supplier: supplier,
        id: id,
        params: _params,
      ))
          .map((item) => RustMediaItem.fromRust(id, supplier, item, _api));
}

extension ContentSearchResultExt on ContentSearchResult {
  static ContentSearchResult fromRust(
      String supplier, models.ContentInfo info) {
    return ContentSearchResult(
      id: info.id,
      supplier: supplier,
      image: info.image,
      title: info.title,
      secondaryTitle: info.secondaryTitle,
    );
  }
}

class RustContentSupplier implements ContentSupplier {
  final RustLibApi _api;

  @override
  final String name;

  RustContentSupplier({required this.name, required RustLibApi api})
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
  Future<ContentDetails?> detailsById(String id) async {
    final result = await _api.crateApiGetContentDetails(
      supplier: name,
      id: id,
    );

    if (result == null) {
      return null;
    }

    return RustContentDetails.fromRust(id, name, result, _api);
  }

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {int page = 0}) async {
    final results = await _api.crateApiLoadChannel(
      supplier: name,
      channel: channel,
      page: page,
    );

    return results
        .map((info) => ContentSearchResultExt.fromRust(name, info))
        .toList();
  }

  @override
  Future<List<ContentInfo>> search(String query, Set<ContentType> type) async {
    final results = await _api.crateApiSearch(
      supplier: name,
      query: query,
      types: type.map((v) => v.name).toList(),
    );

    return results
        .map((info) => ContentSearchResultExt.fromRust(name, info))
        .toList();
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

    return api
        .crateApiAvalaibleSuppliers()
        .map((supplier) => RustContentSupplier(name: supplier, api: api))
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
    externalLibrary =
        await _loadExternalLibrary(defaultExternalLibraryLoaderConfig);

    return initImpl(
      api: null,
      handler: null,
      externalLibrary: externalLibrary,
    );
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

  unload() {
    externalLibrary?.ffiDynamicLibrary.close();
  }
}

FutureOr<ExternalLibrary> _loadExternalLibrary(
    ExternalLibraryLoaderConfig config) async {
  final ioDirectory = config.ioDirectory;

  final stem = config.stem;
  final nativeLibDirWhenNonPackaged =
      ioDirectory == null ? null : Directory.current.uri.resolve(ioDirectory);

  // ref
  // * https://flutter.dev/docs/development/platform-integration/c-interop
  // * https://github.com/fzyzcjy/flutter_rust_bridge/pull/898
  // * https://github.com/flutter/flutter/blob/8b6277e63868c2029f1e2327879b7899be44fbe2/packages/flutter_tools/templates/plugin_ffi/lib/projectName.dart.tmpl#L47-L58

  ExternalLibrary tryAssumingNonPackaged(
      String name, ExternalLibrary Function(String debugInfo) fallback) {
    final effectiveNativeLibDir = Platform
            .environment['FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR']
            ?.toUriDirectory() ??
        nativeLibDirWhenNonPackaged;

    if (effectiveNativeLibDir == null) {
      return fallback(
          '(without trying effectiveNativeLibDir since it is null)');
    }

    final filePath = effectiveNativeLibDir.path + Platform.pathSeparator + name;
    if (!File(filePath).existsSync()) {
      return fallback('(after trying $filePath but it does not exist)');
    }

    return ExternalLibrary.open(filePath);
  }

  if (Platform.isWindows) {
    final name = '$stem.dll';
    return tryAssumingNonPackaged(
        name, (debugInfo) => ExternalLibrary.open(name, debugInfo: debugInfo));
  }

  if (Platform.isIOS || Platform.isMacOS) {
    return tryAssumingNonPackaged(
      'lib$stem.dylib',
      (debugInfo) => _tryOpen(
        'rust_builder.framework/rust_builder',
        debugInfo,
        (debugInfo) =>
            ExternalLibrary.open('$stem.framework/$stem', debugInfo: debugInfo),
      ),
    );
  }

  if (Platform.isLinux || Platform.isAndroid) {
    final name = 'lib$stem.so';
    return tryAssumingNonPackaged(
        name, (debugInfo) => ExternalLibrary.open(name, debugInfo: debugInfo));
  }

  throw Exception(
      'loadExternalLibrary failed: Unknown platform=${Platform.operatingSystem}');
}

ExternalLibrary _tryOpen(String name, String debugInfo,
    ExternalLibrary Function(String debugInfo) fallback) {
  try {
    return ExternalLibrary.open(name, debugInfo: debugInfo);
  } catch (e) {
    return fallback('$debugInfo (after trying $name but has error $e)');
  }
}

extension on String {
  Uri toUriDirectory() => Uri.directory(this);
}
