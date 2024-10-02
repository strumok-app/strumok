// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.4.0.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/bridge.dart';
import 'api/models.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'frb_generated.io.dart'
    if (dart.library.js_interop) 'frb_generated.web.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class RustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  @internal
  static final instance = RustLib._();

  RustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
    );
  }

  /// Initialize flutter_rust_bridge in mock mode.
  /// No libraries for FFI are loaded.
  static void initMock({
    required RustLibApi api,
  }) {
    instance.initMockImpl(
      api: api,
    );
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.crateApiBridgeInitApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  @override
  String get codegenVersion => '2.4.0';

  @override
  int get rustContentHash => -341653949;

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
    stem: 'content_suppliers_rust',
    ioDirectory: 'rust/target/release/',
    webPrefix: 'pkg/',
  );
}

abstract class RustLibApi extends BaseApi {
  List<String> crateApiBridgeAvalaibleSuppliers();

  List<String> crateApiBridgeBridgeGetChannels({required Bridge that});

  Future<ContentDetails?> crateApiBridgeBridgeGetContentDetails(
      {required Bridge that, required String id});

  List<String> crateApiBridgeBridgeGetDefaultChannels({required Bridge that});

  String crateApiBridgeBridgeGetName({required Bridge that});

  List<String> crateApiBridgeBridgeGetSupportedLanguages(
      {required Bridge that});

  List<ContentType> crateApiBridgeBridgeGetSupportedTypes(
      {required Bridge that});

  Future<List<ContentInfo>> crateApiBridgeBridgeLoadChannel(
      {required Bridge that, required String channel, required int page});

  Future<List<ContentMediaItemSource>> crateApiBridgeBridgeLoadMediaItemSources(
      {required Bridge that, required String id, required List<String> params});

  Future<List<ContentMediaItem>> crateApiBridgeBridgeLoadMediaItems(
      {required Bridge that, required String id, required List<String> params});

  Future<List<ContentInfo>> crateApiBridgeBridgeSearch(
      {required Bridge that,
      required String query,
      required List<String> types});

  Future<void> crateApiBridgeInitApp();
}

class RustLibApiImpl extends RustLibApiImplPlatform implements RustLibApi {
  RustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  List<String> crateApiBridgeAvalaibleSuppliers() {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 1)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_String,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeAvalaibleSuppliersConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeAvalaibleSuppliersConstMeta =>
      const TaskConstMeta(
        debugName: "avalaible_suppliers",
        argNames: [],
      );

  @override
  List<String> crateApiBridgeBridgeGetChannels({required Bridge that}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 2)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_String,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeGetChannelsConstMeta,
      argValues: [that],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeGetChannelsConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_get_channels",
        argNames: ["that"],
      );

  @override
  Future<ContentDetails?> crateApiBridgeBridgeGetContentDetails(
      {required Bridge that, required String id}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        sse_encode_String(id, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 3, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_opt_box_autoadd_content_details,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeGetContentDetailsConstMeta,
      argValues: [that, id],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeGetContentDetailsConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_get_content_details",
        argNames: ["that", "id"],
      );

  @override
  List<String> crateApiBridgeBridgeGetDefaultChannels({required Bridge that}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 4)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_String,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeGetDefaultChannelsConstMeta,
      argValues: [that],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeGetDefaultChannelsConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_get_default_channels",
        argNames: ["that"],
      );

  @override
  String crateApiBridgeBridgeGetName({required Bridge that}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 5)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeGetNameConstMeta,
      argValues: [that],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeGetNameConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_get_name",
        argNames: ["that"],
      );

  @override
  List<String> crateApiBridgeBridgeGetSupportedLanguages(
      {required Bridge that}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 6)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_String,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeGetSupportedLanguagesConstMeta,
      argValues: [that],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeGetSupportedLanguagesConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_get_supported_languages",
        argNames: ["that"],
      );

  @override
  List<ContentType> crateApiBridgeBridgeGetSupportedTypes(
      {required Bridge that}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 7)!;
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_content_type,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeGetSupportedTypesConstMeta,
      argValues: [that],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeGetSupportedTypesConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_get_supported_types",
        argNames: ["that"],
      );

  @override
  Future<List<ContentInfo>> crateApiBridgeBridgeLoadChannel(
      {required Bridge that, required String channel, required int page}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        sse_encode_String(channel, serializer);
        sse_encode_u_16(page, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 8, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_content_info,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeLoadChannelConstMeta,
      argValues: [that, channel, page],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeLoadChannelConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_load_channel",
        argNames: ["that", "channel", "page"],
      );

  @override
  Future<List<ContentMediaItemSource>> crateApiBridgeBridgeLoadMediaItemSources(
      {required Bridge that,
      required String id,
      required List<String> params}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        sse_encode_String(id, serializer);
        sse_encode_list_String(params, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 9, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_content_media_item_source,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeLoadMediaItemSourcesConstMeta,
      argValues: [that, id, params],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeLoadMediaItemSourcesConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_load_media_item_sources",
        argNames: ["that", "id", "params"],
      );

  @override
  Future<List<ContentMediaItem>> crateApiBridgeBridgeLoadMediaItems(
      {required Bridge that,
      required String id,
      required List<String> params}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        sse_encode_String(id, serializer);
        sse_encode_list_String(params, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 10, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_content_media_item,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeLoadMediaItemsConstMeta,
      argValues: [that, id, params],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeLoadMediaItemsConstMeta =>
      const TaskConstMeta(
        debugName: "bridge_load_media_items",
        argNames: ["that", "id", "params"],
      );

  @override
  Future<List<ContentInfo>> crateApiBridgeBridgeSearch(
      {required Bridge that,
      required String query,
      required List<String> types}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        sse_encode_box_autoadd_bridge(that, serializer);
        sse_encode_String(query, serializer);
        sse_encode_list_String(types, serializer);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 11, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_list_content_info,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeBridgeSearchConstMeta,
      argValues: [that, query, types],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeBridgeSearchConstMeta => const TaskConstMeta(
        debugName: "bridge_search",
        argNames: ["that", "query", "types"],
      );

  @override
  Future<void> crateApiBridgeInitApp() {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        final serializer = SseSerializer(generalizedFrbRustBinding);
        pdeCallFfi(generalizedFrbRustBinding, serializer,
            funcId: 12, port: port_);
      },
      codec: SseCodec(
        decodeSuccessData: sse_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kCrateApiBridgeInitAppConstMeta,
      argValues: [],
      apiImpl: this,
    ));
  }

  TaskConstMeta get kCrateApiBridgeInitAppConstMeta => const TaskConstMeta(
        debugName: "init_app",
        argNames: [],
      );

  @protected
  Map<String, String> dco_decode_Map_String_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return Map.fromEntries(dco_decode_list_record_string_string(raw)
        .map((e) => MapEntry(e.$1, e.$2)));
  }

  @protected
  String dco_decode_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as String;
  }

  @protected
  Bridge dco_decode_box_autoadd_bridge(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_bridge(raw);
  }

  @protected
  ContentDetails dco_decode_box_autoadd_content_details(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_content_details(raw);
  }

  @protected
  Bridge dco_decode_bridge(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 1)
      throw Exception('unexpected arr length: expect 1 but see ${arr.length}');
    return Bridge(
      name: dco_decode_String(arr[0]),
    );
  }

  @protected
  ContentDetails dco_decode_content_details(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 10)
      throw Exception('unexpected arr length: expect 10 but see ${arr.length}');
    return ContentDetails(
      id: dco_decode_String(arr[0]),
      supplier: dco_decode_String(arr[1]),
      title: dco_decode_String(arr[2]),
      originalTitle: dco_decode_opt_String(arr[3]),
      image: dco_decode_String(arr[4]),
      description: dco_decode_String(arr[5]),
      mediaType: dco_decode_media_type(arr[6]),
      additionalInfo: dco_decode_list_String(arr[7]),
      similar: dco_decode_list_content_info(arr[8]),
      params: dco_decode_list_String(arr[9]),
    );
  }

  @protected
  ContentInfo dco_decode_content_info(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 5)
      throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
    return ContentInfo(
      id: dco_decode_String(arr[0]),
      supplier: dco_decode_String(arr[1]),
      title: dco_decode_String(arr[2]),
      secondaryTitle: dco_decode_opt_String(arr[3]),
      image: dco_decode_String(arr[4]),
    );
  }

  @protected
  ContentMediaItem dco_decode_content_media_item(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 5)
      throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
    return ContentMediaItem(
      number: dco_decode_u_16(arr[0]),
      title: dco_decode_String(arr[1]),
      section: dco_decode_opt_String(arr[2]),
      image: dco_decode_opt_String(arr[3]),
      params: dco_decode_list_String(arr[4]),
    );
  }

  @protected
  ContentMediaItemSource dco_decode_content_media_item_source(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    switch (raw[0]) {
      case 0:
        return ContentMediaItemSource_Video(
          link: dco_decode_String(raw[1]),
          description: dco_decode_String(raw[2]),
          headers: dco_decode_Map_String_String(raw[3]),
        );
      case 1:
        return ContentMediaItemSource_Subtitle(
          link: dco_decode_String(raw[1]),
          description: dco_decode_String(raw[2]),
          headers: dco_decode_Map_String_String(raw[3]),
        );
      case 2:
        return ContentMediaItemSource_Manga(
          description: dco_decode_String(raw[1]),
          pages: dco_decode_list_String(raw[2]),
        );
      default:
        throw Exception("unreachable");
    }
  }

  @protected
  ContentType dco_decode_content_type(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return ContentType.values[raw as int];
  }

  @protected
  int dco_decode_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  List<String> dco_decode_list_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_String).toList();
  }

  @protected
  List<ContentInfo> dco_decode_list_content_info(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_content_info).toList();
  }

  @protected
  List<ContentMediaItem> dco_decode_list_content_media_item(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_content_media_item).toList();
  }

  @protected
  List<ContentMediaItemSource> dco_decode_list_content_media_item_source(
      dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>)
        .map(dco_decode_content_media_item_source)
        .toList();
  }

  @protected
  List<ContentType> dco_decode_list_content_type(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_content_type).toList();
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint8List;
  }

  @protected
  List<(String, String)> dco_decode_list_record_string_string(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_record_string_string).toList();
  }

  @protected
  MediaType dco_decode_media_type(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return MediaType.values[raw as int];
  }

  @protected
  String? dco_decode_opt_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_String(raw);
  }

  @protected
  ContentDetails? dco_decode_opt_box_autoadd_content_details(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_box_autoadd_content_details(raw);
  }

  @protected
  (String, String) dco_decode_record_string_string(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2) {
      throw Exception('Expected 2 elements, got ${arr.length}');
    }
    return (
      dco_decode_String(arr[0]),
      dco_decode_String(arr[1]),
    );
  }

  @protected
  int dco_decode_u_16(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return;
  }

  @protected
  Map<String, String> sse_decode_Map_String_String(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_record_string_string(deserializer);
    return Map.fromEntries(inner.map((e) => MapEntry(e.$1, e.$2)));
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  Bridge sse_decode_box_autoadd_bridge(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_bridge(deserializer));
  }

  @protected
  ContentDetails sse_decode_box_autoadd_content_details(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_content_details(deserializer));
  }

  @protected
  Bridge sse_decode_bridge(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_name = sse_decode_String(deserializer);
    return Bridge(name: var_name);
  }

  @protected
  ContentDetails sse_decode_content_details(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_String(deserializer);
    var var_supplier = sse_decode_String(deserializer);
    var var_title = sse_decode_String(deserializer);
    var var_originalTitle = sse_decode_opt_String(deserializer);
    var var_image = sse_decode_String(deserializer);
    var var_description = sse_decode_String(deserializer);
    var var_mediaType = sse_decode_media_type(deserializer);
    var var_additionalInfo = sse_decode_list_String(deserializer);
    var var_similar = sse_decode_list_content_info(deserializer);
    var var_params = sse_decode_list_String(deserializer);
    return ContentDetails(
        id: var_id,
        supplier: var_supplier,
        title: var_title,
        originalTitle: var_originalTitle,
        image: var_image,
        description: var_description,
        mediaType: var_mediaType,
        additionalInfo: var_additionalInfo,
        similar: var_similar,
        params: var_params);
  }

  @protected
  ContentInfo sse_decode_content_info(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_String(deserializer);
    var var_supplier = sse_decode_String(deserializer);
    var var_title = sse_decode_String(deserializer);
    var var_secondaryTitle = sse_decode_opt_String(deserializer);
    var var_image = sse_decode_String(deserializer);
    return ContentInfo(
        id: var_id,
        supplier: var_supplier,
        title: var_title,
        secondaryTitle: var_secondaryTitle,
        image: var_image);
  }

  @protected
  ContentMediaItem sse_decode_content_media_item(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_number = sse_decode_u_16(deserializer);
    var var_title = sse_decode_String(deserializer);
    var var_section = sse_decode_opt_String(deserializer);
    var var_image = sse_decode_opt_String(deserializer);
    var var_params = sse_decode_list_String(deserializer);
    return ContentMediaItem(
        number: var_number,
        title: var_title,
        section: var_section,
        image: var_image,
        params: var_params);
  }

  @protected
  ContentMediaItemSource sse_decode_content_media_item_source(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var tag_ = sse_decode_i_32(deserializer);
    switch (tag_) {
      case 0:
        var var_link = sse_decode_String(deserializer);
        var var_description = sse_decode_String(deserializer);
        var var_headers = sse_decode_Map_String_String(deserializer);
        return ContentMediaItemSource_Video(
            link: var_link, description: var_description, headers: var_headers);
      case 1:
        var var_link = sse_decode_String(deserializer);
        var var_description = sse_decode_String(deserializer);
        var var_headers = sse_decode_Map_String_String(deserializer);
        return ContentMediaItemSource_Subtitle(
            link: var_link, description: var_description, headers: var_headers);
      case 2:
        var var_description = sse_decode_String(deserializer);
        var var_pages = sse_decode_list_String(deserializer);
        return ContentMediaItemSource_Manga(
            description: var_description, pages: var_pages);
      default:
        throw UnimplementedError('');
    }
  }

  @protected
  ContentType sse_decode_content_type(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_32(deserializer);
    return ContentType.values[inner];
  }

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt32();
  }

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <String>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_String(deserializer));
    }
    return ans_;
  }

  @protected
  List<ContentInfo> sse_decode_list_content_info(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <ContentInfo>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_content_info(deserializer));
    }
    return ans_;
  }

  @protected
  List<ContentMediaItem> sse_decode_list_content_media_item(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <ContentMediaItem>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_content_media_item(deserializer));
    }
    return ans_;
  }

  @protected
  List<ContentMediaItemSource> sse_decode_list_content_media_item_source(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <ContentMediaItemSource>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_content_media_item_source(deserializer));
    }
    return ans_;
  }

  @protected
  List<ContentType> sse_decode_list_content_type(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <ContentType>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_content_type(deserializer));
    }
    return ans_;
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  List<(String, String)> sse_decode_list_record_string_string(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <(String, String)>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_record_string_string(deserializer));
    }
    return ans_;
  }

  @protected
  MediaType sse_decode_media_type(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_32(deserializer);
    return MediaType.values[inner];
  }

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_String(deserializer));
    } else {
      return null;
    }
  }

  @protected
  ContentDetails? sse_decode_opt_box_autoadd_content_details(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_box_autoadd_content_details(deserializer));
    } else {
      return null;
    }
  }

  @protected
  (String, String) sse_decode_record_string_string(
      SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_field0 = sse_decode_String(deserializer);
    var var_field1 = sse_decode_String(deserializer);
    return (var_field0, var_field1);
  }

  @protected
  int sse_decode_u_16(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint16();
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  void sse_encode_Map_String_String(
      Map<String, String> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_record_string_string(
        self.entries.map((e) => (e.key, e.value)).toList(), serializer);
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_box_autoadd_bridge(Bridge self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_bridge(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_content_details(
      ContentDetails self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_content_details(self, serializer);
  }

  @protected
  void sse_encode_bridge(Bridge self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.name, serializer);
  }

  @protected
  void sse_encode_content_details(
      ContentDetails self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.id, serializer);
    sse_encode_String(self.supplier, serializer);
    sse_encode_String(self.title, serializer);
    sse_encode_opt_String(self.originalTitle, serializer);
    sse_encode_String(self.image, serializer);
    sse_encode_String(self.description, serializer);
    sse_encode_media_type(self.mediaType, serializer);
    sse_encode_list_String(self.additionalInfo, serializer);
    sse_encode_list_content_info(self.similar, serializer);
    sse_encode_list_String(self.params, serializer);
  }

  @protected
  void sse_encode_content_info(ContentInfo self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.id, serializer);
    sse_encode_String(self.supplier, serializer);
    sse_encode_String(self.title, serializer);
    sse_encode_opt_String(self.secondaryTitle, serializer);
    sse_encode_String(self.image, serializer);
  }

  @protected
  void sse_encode_content_media_item(
      ContentMediaItem self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_u_16(self.number, serializer);
    sse_encode_String(self.title, serializer);
    sse_encode_opt_String(self.section, serializer);
    sse_encode_opt_String(self.image, serializer);
    sse_encode_list_String(self.params, serializer);
  }

  @protected
  void sse_encode_content_media_item_source(
      ContentMediaItemSource self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    switch (self) {
      case ContentMediaItemSource_Video(
          link: final link,
          description: final description,
          headers: final headers
        ):
        sse_encode_i_32(0, serializer);
        sse_encode_String(link, serializer);
        sse_encode_String(description, serializer);
        sse_encode_Map_String_String(headers, serializer);
      case ContentMediaItemSource_Subtitle(
          link: final link,
          description: final description,
          headers: final headers
        ):
        sse_encode_i_32(1, serializer);
        sse_encode_String(link, serializer);
        sse_encode_String(description, serializer);
        sse_encode_Map_String_String(headers, serializer);
      case ContentMediaItemSource_Manga(
          description: final description,
          pages: final pages
        ):
        sse_encode_i_32(2, serializer);
        sse_encode_String(description, serializer);
        sse_encode_list_String(pages, serializer);
      default:
        throw UnimplementedError('');
    }
  }

  @protected
  void sse_encode_content_type(ContentType self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.index, serializer);
  }

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt32(self);
  }

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_String(item, serializer);
    }
  }

  @protected
  void sse_encode_list_content_info(
      List<ContentInfo> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_content_info(item, serializer);
    }
  }

  @protected
  void sse_encode_list_content_media_item(
      List<ContentMediaItem> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_content_media_item(item, serializer);
    }
  }

  @protected
  void sse_encode_list_content_media_item_source(
      List<ContentMediaItemSource> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_content_media_item_source(item, serializer);
    }
  }

  @protected
  void sse_encode_list_content_type(
      List<ContentType> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_content_type(item, serializer);
    }
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_list_record_string_string(
      List<(String, String)> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_record_string_string(item, serializer);
    }
  }

  @protected
  void sse_encode_media_type(MediaType self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.index, serializer);
  }

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_String(self, serializer);
    }
  }

  @protected
  void sse_encode_opt_box_autoadd_content_details(
      ContentDetails? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_box_autoadd_content_details(self, serializer);
    }
  }

  @protected
  void sse_encode_record_string_string(
      (String, String) self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.$1, serializer);
    sse_encode_String(self.$2, serializer);
  }

  @protected
  void sse_encode_u_16(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint16(self);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }
}
