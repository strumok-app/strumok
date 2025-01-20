import 'dart:convert';

import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late final SharedPreferences instance;
  static const Color defaultColor = Colors.green;

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static Set<ContentLanguage>? get selectedContentLanguage => instance
      .getStringList("selected_content_language")
      ?.map(
        (value) => ContentLanguage.values.firstWhereOrNull((lang) => lang.name == value),
      )
      .nonNulls
      .toSet();

  static set selectedContentLanguage(Set<ContentLanguage>? value) => instance.setStringList(
        "selected_content_language",
        value?.map((lang) => lang.name).toList() ?? List.empty(),
      );

  static Set<ContentType>? get searchContentType => instance
      .getStringList("selected_content_type")
      ?.map(
        (value) => ContentType.values.firstWhereOrNull((type) => type.name == value),
      )
      .nonNulls
      .toSet();

  static set searchContentType(Set<ContentType>? value) => instance.setStringList(
        "selected_content_type",
        value?.map((type) => type.name).toList() ?? List.empty(),
      );

  static Set<String>? get searchContentSuppliers => instance.getStringList("selected_content_suppliers")?.toSet();

  static set searchContentSuppliers(Set<String>? value) => instance.setStringList(
        "selected_content_suppliers",
        value?.toList() ?? List.empty(),
      );

  static set themeBrightness(Brightness? brightness) => brightness != null
      ? instance.setString("theme_brightness", brightness.name)
      : instance.remove("theme_brightness");

  static Brightness? get themeBrightness => Brightness.values
      .where(
        (type) => type.name == instance.getString("theme_brightness"),
      )
      .firstOrNull;

  static set themeColor(Color color) => instance.setInt("theme_color", color.value);

  static Color get themeColor {
    final colorValue = instance.getInt("theme_color");
    // colorValue
    return colorValue != null ? Color(colorValue) : defaultColor;
  }

  // static Set<MediaType>? get collectionMediaType => instance
  //     .getStringList("collection_media_type")
  //     ?.map(
  //       (value) => MediaType.values.firstWhereOrNull((type) => type.name == value),
  //     )
  //     .nonNulls
  //     .toSet();

  // static set collectionMediaType(
  //   Set<MediaType>? value,
  // ) =>
  //     instance.setStringList(
  //       "collection_media_type",
  //       value?.map((type) => type.name).toList() ?? List.empty(),
  //     );

  // static Set<MediaCollectionItemStatus>? get collectionItemStatus => instance
  //     .getStringList("collection_item_status")
  //     ?.map(
  //       (value) => MediaCollectionItemStatus.values.firstWhereOrNull((type) => type.name == value),
  //     )
  //     .nonNulls
  //     .toSet();

  // static set collectionItemStatus(
  //   Set<MediaCollectionItemStatus>? value,
  // ) =>
  //     instance.setStringList(
  //       "collection_item_status",
  //       value?.map((type) => type.name).toList() ?? List.empty(),
  //     );

  // static Set<String>? get collectionContentSuppliers => instance.getStringList("collection_content_suppliers")?.toSet();

  // static set collectionContentSuppliers(Set<String>? value) => instance.setStringList(
  //       "collection_content_suppliers",
  //       value?.toList() ?? List.empty(),
  //     );

  static int get lastSyncTimestamp => instance.getInt("last_sync_timestamp") ?? 0;

  static set lastSyncTimestamp(int timestamp) => instance.setInt("last_sync_timestamp", timestamp);

  static double get volume => instance.getDouble("volume") ?? 100.0;

  static set volume(double value) => instance.setDouble("volume", value);

  static List<String>? get suppliersOrder => instance.getStringList("suppliers_order");

  static set suppliersOrder(List<String>? value) => instance.setStringList("suppliers_order", value ?? []);

  static void setSupplierEnabled(
    String supplierName,
    bool enabled,
  ) {
    instance.setBool("suppliers.$supplierName.enabled", enabled);
  }

  static bool? getSupplierEnabled(String supplierName) => instance.getBool("suppliers.$supplierName.enabled");

  static void setSupplierChannels(
    String supplierName,
    Set<String> channels,
  ) {
    instance.setStringList(
      "suppliers.$supplierName.channels",
      channels.toList(),
    );
  }

  static Set<String>? getSupplierChannels(String supplierName) =>
      instance.getStringList("suppliers.$supplierName.channels")?.toSet();

  static set mangaReaderScale(MangaReaderScale scale) => instance.setString("manga_reader_scale", scale.name);

  static MangaReaderScale get mangaReaderScale =>
      MangaReaderScale.values
          .where(
            (type) => type.name == instance.getString("manga_reader_scale"),
          )
          .firstOrNull ??
      MangaReaderScale.fit;

  static set mangaReaderBackground(MangaReaderBackground background) =>
      instance.setString("manga_reader_background", background.name);

  static MangaReaderBackground get mangaReaderBackground =>
      MangaReaderBackground.values
          .where(
            (type) => type.name == instance.getString("manga_reader_background"),
          )
          .firstOrNull ??
      MangaReaderBackground.dark;

  static set mangaReaderMode(MangaReaderMode mode) => instance.setString("manga_reader_mode", mode.name);

  static MangaReaderMode get mangaReaderMode =>
      MangaReaderMode.values.where((type) => type.name == instance.getString("manga_reader_mode")).firstOrNull ??
      MangaReaderMode.vericalScroll;

  static bool get videoPlayerSettingShuffleMode => instance.getBool("video_player_setting_shuffle_mode") ?? false;

  static set videoPlayerSettingShuffleMode(bool enabled) =>
      instance.setBool("video_player_setting_shuffle_mode", enabled);

  static OnVideoEndsAction get videoPlayerSettingEndsAction =>
      OnVideoEndsAction.values
          .where((action) => action.name == instance.getString("video_player_setting_ends_action"))
          .firstOrNull ??
      OnVideoEndsAction.playNext;

  static set videoPlayerSettingEndsAction(OnVideoEndsAction action) =>
      instance.setString("video_player_setting_ends_action", action.name);

  static StarVideoPosition get videoPlayerSettingStarFrom =>
      StarVideoPosition.values
          .where((startFrom) => startFrom.name == instance.getString("video_player_setting_star_from"))
          .firstOrNull ??
      StarVideoPosition.fromRemembered;

  static set videoPlayerSettingStarFrom(StarVideoPosition startFrom) =>
      instance.setString("video_player_setting_star_from", startFrom.name);

  static int get videoPlayerSettingFixedPosition => instance.getInt("video_player_setting_fixed_position") ?? 0;

  static set videoPlayerSettingFixedPosition(int pos) => instance.setInt("video_player_setting_fixed_position", pos);

  static set ffiSupplierBundleInfo(FFISupplierBundleInfo? info) {
    if (info == null) {
      instance.remove("ffi_supplier_bundle_info");
      return;
    }

    final infoJson = json.encode(info.toJson());

    instance.setString("ffi_supplier_bundle_info", infoJson);
  }

  static FFISupplierBundleInfo? get ffiSupplierBundleInfo {
    final infoJson = instance.getString("ffi_supplier_bundle_info");

    if (infoJson == null) {
      return null;
    }

    return FFISupplierBundleInfo.fromJson(json.decode(infoJson));
  }
}
