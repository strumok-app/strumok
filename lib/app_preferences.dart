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
  // Preference key constants
  static const String _keySelectedContentLanguage = "selected_content_language";
  static const String _keySelectedContentType = "selected_content_type";
  static const String _keySelectedContentSuppliers =
      "selected_content_suppliers";
  static const String _keyUserLanguage = "user_language";
  static const String _keyThemeBrightness = "theme_brightness";
  static const String _keyThemeColor = "theme_color";
  static const String _keyLastSyncTs = "last_sync_ts";
  static const String _keyVolume = "volume";
  static const String _keySuppliersOrder = "suppliers_order";
  static const String _keyMangaReaderBackground = "manga_reader_background";
  static const String _keyMangaReaderMode = "manga_reader_mode";
  static const String _keyMangaReaderAutoCrop = "manga_reader_auto_crop";
  static const String _keyVideoPlayerSettingShuffleMode =
      "video_player_setting_shuffle_mode";
  static const String _keyVideoPlayerSettingEndsAction =
      "video_player_setting_ends_action";
  static const String _keyVideoPlayerSettingStartFrom =
      "video_player_setting_start_from";
  static const String _keyVideoPlayerSettingFixedPosition =
      "video_player_setting_fixed_position";
  static const String _keyVideoPlayerEqualizerBands =
      "video_player_equalizer_bands";
  static const String _keyOfflineMode = "offline_mode";
  static const String _keyOfflineDownloadsDirectory = "offline_downloads_directory";
  static const String _keyFfiSupplierBundleInfo = "ffi_supplier_bundle_info";

  static late final SharedPreferences instance;

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }

  static Set<ContentLanguage>? get selectedContentLanguage => instance
      .getStringList(_keySelectedContentLanguage)
      ?.map(
        (value) => ContentLanguage.values.firstWhereOrNull(
          (lang) => lang.name == value,
        ),
      )
      .nonNulls
      .toSet();

  static Set<String>? get selectedContentLanguageCodes =>
      instance.getStringList(_keySelectedContentLanguage)?.toSet();

  static set selectedContentLanguage(Set<ContentLanguage>? value) =>
      instance.setStringList(
        _keySelectedContentLanguage,
        value?.map((lang) => lang.name).toList() ?? List.empty(),
      );

  static Set<ContentType>? get searchContentType => instance
      .getStringList(_keySelectedContentType)
      ?.map(
        (value) =>
            ContentType.values.firstWhereOrNull((type) => type.name == value),
      )
      .nonNulls
      .toSet();

  static set searchContentType(Set<ContentType>? value) =>
      instance.setStringList(
        _keySelectedContentType,
        value?.map((type) => type.name).toList() ?? List.empty(),
      );

  static Set<String>? get searchContentSuppliers =>
      instance.getStringList(_keySelectedContentSuppliers)?.toSet();

  static set searchContentSuppliers(Set<String>? value) =>
      instance.setStringList(
        _keySelectedContentSuppliers,
        value?.toList() ?? List.empty(),
      );

  static set userLanguage(String? lang) => lang != null
      ? instance.setString(_keyUserLanguage, lang)
      : instance.remove(_keyUserLanguage);

  static String? get userLanguage => instance.getString(_keyUserLanguage);

  static set themeBrightness(Brightness? brightness) => brightness != null
      ? instance.setString(_keyThemeBrightness, brightness.name)
      : instance.remove(_keyThemeBrightness);

  static Brightness? get themeBrightness => Brightness.values
      .where((type) => type.name == instance.getString(_keyThemeBrightness))
      .firstOrNull;

  static set themeColor(Color color) =>
      instance.setInt(_keyThemeColor, color.toARGB32());

  static Color get themeColor {
    final colorValue = instance.getInt(_keyThemeColor);
    // colorValue
    return colorValue != null ? Color(colorValue) : AppConstances.defaultColor;
  }

  static int get lastSyncTimestamp => instance.getInt(_keyLastSyncTs) ?? 0;

  static set lastSyncTimestamp(int timestamp) =>
      instance.setInt(_keyLastSyncTs, timestamp);

  static double get volume => instance.getDouble(_keyVolume) ?? 100.0;

  static set volume(double value) => instance.setDouble(_keyVolume, value);

  static List<String>? get suppliersOrder =>
      instance.getStringList(_keySuppliersOrder);

  static set suppliersOrder(List<String>? value) =>
      instance.setStringList(_keySuppliersOrder, value ?? []);

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
      instance.setString(_keyMangaReaderBackground, background.name);

  static MangaReaderBackground get mangaReaderBackground =>
      MangaReaderBackground.values
          .where(
            (type) =>
                type.name == instance.getString(_keyMangaReaderBackground),
          )
          .firstOrNull ??
      MangaReaderBackground.dark;

  static set mangaReaderMode(MangaReaderMode mode) =>
      instance.setString(_keyMangaReaderMode, mode.name);

  static MangaReaderMode get mangaReaderMode =>
      MangaReaderMode.values
          .where((type) => type.name == instance.getString(_keyMangaReaderMode))
          .firstOrNull ??
      MangaReaderMode.longStrip;

  static bool get mangaReaderAutoCrop =>
      instance.getBool(_keyMangaReaderAutoCrop) ?? true;

  static set mangaReaderAutoCrop(bool enabled) =>
      instance.setBool(_keyMangaReaderAutoCrop, enabled);

  static bool get videoPlayerSettingShuffleMode =>
      instance.getBool(_keyVideoPlayerSettingShuffleMode) ?? false;

  static set videoPlayerSettingShuffleMode(bool enabled) =>
      instance.setBool(_keyVideoPlayerSettingShuffleMode, enabled);

  static OnVideoEndsAction get videoPlayerSettingEndsAction =>
      OnVideoEndsAction.values
          .where(
            (action) =>
                action.name ==
                instance.getString(_keyVideoPlayerSettingEndsAction),
          )
          .firstOrNull ??
      OnVideoEndsAction.playNext;

  static set videoPlayerSettingEndsAction(OnVideoEndsAction action) =>
      instance.setString(_keyVideoPlayerSettingEndsAction, action.name);

  static StartVideoPosition get videoPlayerSettingStarFrom =>
      StartVideoPosition.values
          .where(
            (startFrom) =>
                startFrom.name ==
                instance.getString(_keyVideoPlayerSettingStartFrom),
          )
          .firstOrNull ??
      StartVideoPosition.fromRemembered;

  static set videoPlayerSettingStarFrom(StartVideoPosition startFrom) =>
      instance.setString(_keyVideoPlayerSettingStartFrom, startFrom.name);

  static int get videoPlayerSettingFixedPosition =>
      instance.getInt(_keyVideoPlayerSettingFixedPosition) ?? 0;

  static set videoPlayerSettingFixedPosition(int pos) =>
      instance.setInt(_keyVideoPlayerSettingFixedPosition, pos);

  static List<double> get videoPlayerEqualizerBands {
    final bandsString = instance.getString(_keyVideoPlayerEqualizerBands);
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
    instance.setString(_keyVideoPlayerEqualizerBands, bandsString);
  }

  static bool get offlineMode => instance.getBool(_keyOfflineMode) ?? false;

  static set offlineMode(bool mode) => instance.setBool(_keyOfflineMode, mode);

  static String? get offlineDownloadsDirectory => instance.getString(_keyOfflineDownloadsDirectory);

  static set offlineDownloadsDirectory(String? path) => path != null
      ? instance.setString(_keyOfflineDownloadsDirectory, path)
      : instance.remove(_keyOfflineDownloadsDirectory);

  static set ffiSupplierBundleInfo(FFISupplierBundleInfo? info) {
    if (info == null) {
      instance.remove(_keyFfiSupplierBundleInfo);
      return;
    }

    final infoJson = json.encode(info.toJson());

    instance.setString(_keyFfiSupplierBundleInfo, infoJson);
  }

  static FFISupplierBundleInfo? get ffiSupplierBundleInfo {
    final infoJson = instance.getString(_keyFfiSupplierBundleInfo);

    if (infoJson == null) {
      return null;
    }

    return FFISupplierBundleInfo.fromJson(json.decode(infoJson));
  }
}
