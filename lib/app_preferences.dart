import 'dart:convert';

import 'package:strumok/content/manga/model.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstances {
  static const Color defaultColor = Colors.green;
  static const equalizerBandsFreq = [60, 230, 910, 4000, 14000];
  static const equalizerDefaultBands = [0.0, 0.0, 0.0, 0.0, 0.0];
  static const equalizerMaxBands = [12.0, 12.0, 12.0, 12.0, 12.0];
  static const equalizerClearDialogBands = [0.0, 2.0, 4.0, 5.0, 1.0];
  static const equalizerCinemaBands = [4.0, 2.0, 0.0, 2.0, 4.0];
  static const equalizerNightModeBands = [-3.0, 0.0, 3.0, 4.0, -2.0];
  static const equalizerActionBands = [5.0, 3.0, -1.0, 1.0, 3.0];
}

class AppPreferences {
  static late final SharedPreferences instance;

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static Set<ContentLanguage>? get selectedContentLanguage => instance
      .getStringList("selected_content_language")
      ?.map(
        (value) => ContentLanguage.values.firstWhereOrNull(
          (lang) => lang.name == value,
        ),
      )
      .nonNulls
      .toSet();

  static set selectedContentLanguage(Set<ContentLanguage>? value) =>
      instance.setStringList(
        "selected_content_language",
        value?.map((lang) => lang.name).toList() ?? List.empty(),
      );

  static Set<ContentType>? get searchContentType => instance
      .getStringList("selected_content_type")
      ?.map(
        (value) =>
            ContentType.values.firstWhereOrNull((type) => type.name == value),
      )
      .nonNulls
      .toSet();

  static set searchContentType(Set<ContentType>? value) =>
      instance.setStringList(
        "selected_content_type",
        value?.map((type) => type.name).toList() ?? List.empty(),
      );

  static Set<String>? get searchContentSuppliers =>
      instance.getStringList("selected_content_suppliers")?.toSet();

  static set searchContentSuppliers(Set<String>? value) =>
      instance.setStringList(
        "selected_content_suppliers",
        value?.toList() ?? List.empty(),
      );

  static set userLanguage(String? lang) => lang != null
      ? instance.setString("user_language", lang)
      : instance.remove("user_language");

  static String? get userLanguage => instance.getString("user_language");

  static set themeBrightness(Brightness? brightness) => brightness != null
      ? instance.setString("theme_brightness", brightness.name)
      : instance.remove("theme_brightness");

  static Brightness? get themeBrightness => Brightness.values
      .where((type) => type.name == instance.getString("theme_brightness"))
      .firstOrNull;

  static set themeColor(Color color) =>
      instance.setInt("theme_color", color.toARGB32());

  static Color get themeColor {
    final colorValue = instance.getInt("theme_color");
    // colorValue
    return colorValue != null ? Color(colorValue) : AppConstances.defaultColor;
  }

  static int get lastSyncTimestamp => instance.getInt("last_sync_ts") ?? 0;

  static set lastSyncTimestamp(int timestamp) =>
      instance.setInt("last_sync_ts", timestamp);

  static double get volume => instance.getDouble("volume") ?? 100.0;

  static set volume(double value) => instance.setDouble("volume", value);

  static List<String>? get suppliersOrder =>
      instance.getStringList("suppliers_order");

  static set suppliersOrder(List<String>? value) =>
      instance.setStringList("suppliers_order", value ?? []);

  static void setSupplierEnabled(String supplierName, bool enabled) {
    instance.setBool("suppliers.$supplierName.enabled", enabled);
  }

  static bool? getSupplierEnabled(String supplierName) =>
      instance.getBool("suppliers.$supplierName.enabled");

  static void setSupplierChannels(String supplierName, Set<String> channels) {
    instance.setStringList(
      "suppliers.$supplierName.channels",
      channels.toList(),
    );
  }

  static Set<String>? getSupplierChannels(String supplierName) =>
      instance.getStringList("suppliers.$supplierName.channels")?.toSet();

  static set mangaReaderBackground(MangaReaderBackground background) =>
      instance.setString("manga_reader_background", background.name);

  static MangaReaderBackground get mangaReaderBackground =>
      MangaReaderBackground.values
          .where(
            (type) =>
                type.name == instance.getString("manga_reader_background"),
          )
          .firstOrNull ??
      MangaReaderBackground.dark;

  static set mangaReaderMode(MangaReaderMode mode) =>
      instance.setString("manga_reader_mode", mode.name);

  static MangaReaderMode get mangaReaderMode =>
      MangaReaderMode.values
          .where((type) => type.name == instance.getString("manga_reader_mode"))
          .firstOrNull ??
      MangaReaderMode.longStrip;

  static bool get videoPlayerSettingShuffleMode =>
      instance.getBool("video_player_setting_shuffle_mode") ?? false;

  static set videoPlayerSettingShuffleMode(bool enabled) =>
      instance.setBool("video_player_setting_shuffle_mode", enabled);

  static OnVideoEndsAction get videoPlayerSettingEndsAction =>
      OnVideoEndsAction.values
          .where(
            (action) =>
                action.name ==
                instance.getString("video_player_setting_ends_action"),
          )
          .firstOrNull ??
      OnVideoEndsAction.playNext;

  static set videoPlayerSettingEndsAction(OnVideoEndsAction action) =>
      instance.setString("video_player_setting_ends_action", action.name);

  static StartVideoPosition get videoPlayerSettingStarFrom =>
      StartVideoPosition.values
          .where(
            (startFrom) =>
                startFrom.name ==
                instance.getString("video_player_setting_start_from"),
          )
          .firstOrNull ??
      StartVideoPosition.fromRemembered;

  static set videoPlayerSettingStarFrom(StartVideoPosition startFrom) =>
      instance.setString("video_player_setting_start_from", startFrom.name);

  static int get videoPlayerSettingFixedPosition =>
      instance.getInt("video_player_setting_fixed_position") ?? 0;

  static set videoPlayerSettingFixedPosition(int pos) =>
      instance.setInt("video_player_setting_fixed_position", pos);

  static List<double> get videoPlayerEqualizerBands {
    final bandsString = instance.getString("video_player_equalizer_bands");
    if (bandsString == null) {
      return AppConstances.equalizerDefaultBands;
    }

    final bands = bandsString
        .split(',')
        .map((e) => double.tryParse(e) ?? 0)
        .toList();

    return bands.length == 5 ? bands : AppConstances.equalizerDefaultBands;
  }

  static set videoPlayerEqualizerBands(List<double> bands) {
    final bandsString = bands.map((e) => e.toString()).join(',');
    instance.setString("video_player_equalizer_bands", bandsString);
  }

  static bool get offlineMode => instance.getBool("offline_mode") ?? false;

  static set offlineMode(bool mode) => instance.setBool("offline_mode", mode);

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
