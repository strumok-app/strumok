// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.7.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'frb_generated.dart';
import 'models.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

List<String> getChannels({required String supplier}) =>
    RustLib.instance.api.crateApiGetChannels(supplier: supplier);

List<String> getDefaultChannels({required String supplier}) =>
    RustLib.instance.api.crateApiGetDefaultChannels(supplier: supplier);

List<ContentType> getSupportedTypes({required String supplier}) =>
    RustLib.instance.api.crateApiGetSupportedTypes(supplier: supplier);

List<String> getSupportedLanguages({required String supplier}) =>
    RustLib.instance.api.crateApiGetSupportedLanguages(supplier: supplier);

Future<List<ContentInfo>> search(
        {required String supplier,
        required String query,
        required List<String> types}) =>
    RustLib.instance.api
        .crateApiSearch(supplier: supplier, query: query, types: types);

Future<List<ContentInfo>> loadChannel(
        {required String supplier,
        required String channel,
        required int page}) =>
    RustLib.instance.api
        .crateApiLoadChannel(supplier: supplier, channel: channel, page: page);

Future<ContentDetails?> getContentDetails(
        {required String supplier, required String id}) =>
    RustLib.instance.api.crateApiGetContentDetails(supplier: supplier, id: id);

Future<List<ContentMediaItem>> loadMediaItems(
        {required String supplier,
        required String id,
        required List<String> params}) =>
    RustLib.instance.api
        .crateApiLoadMediaItems(supplier: supplier, id: id, params: params);

Future<List<ContentMediaItemSource>> loadMediaItemSources(
        {required String supplier,
        required String id,
        required List<String> params}) =>
    RustLib.instance.api.crateApiLoadMediaItemSources(
        supplier: supplier, id: id, params: params);

Future<List<String>> loadMangaPages(
        {required String supplier,
        required String id,
        required List<String> params}) =>
    RustLib.instance.api
        .crateApiLoadMangaPages(supplier: supplier, id: id, params: params);

List<String> avalaibleSuppliers() =>
    RustLib.instance.api.crateApiAvalaibleSuppliers();
