import 'package:content_suppliers_api/model.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/offline_storage.dart';
import 'package:strumok/utils/collections.dart';
import 'dart:io';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class OfflineMode extends _$OfflineMode {
  @override
  bool build() {
    return AppPreferences.offlineMode;
  }

  void select(bool mode) {
    AppPreferences.offlineMode = mode;
    state = mode;
  }
}

@Riverpod(keepAlive: true)
class BrightnessSetting extends _$BrightnessSetting {
  @override
  Brightness? build() {
    return AppPreferences.themeBrightness;
  }

  void select(Brightness? brightness) {
    AppPreferences.themeBrightness = brightness;
    state = brightness;
  }
}

@Riverpod(keepAlive: true)
class ColorSettings extends _$ColorSettings {
  @override
  Color build() {
    return AppPreferences.themeColor;
  }

  void select(Color color) {
    AppPreferences.themeColor = color;
    state = color;
  }
}

@Riverpod(keepAlive: true)
class UserLanguageSetting extends _$UserLanguageSetting {
  @override
  String build() {
    final [localeLang, ...] = Platform.localeName.split("_");
    return AppPreferences.userLanguage ?? localeLang;
  }

  void select(String lang) {
    state = lang;
    AppPreferences.userLanguage = lang;
  }
}

@Riverpod(keepAlive: true)
class MangaReaderBackgroundSettings extends _$MangaReaderBackgroundSettings {
  @override
  MangaReaderBackground build() {
    return AppPreferences.mangaReaderBackground;
  }

  void select(MangaReaderBackground background) {
    AppPreferences.mangaReaderBackground = background;
    state = background;
  }
}

@Riverpod(keepAlive: true)
class MangaReaderModeSettings extends _$MangaReaderModeSettings {
  @override
  MangaReaderMode build() {
    return AppPreferences.mangaReaderMode;
  }

  void select(MangaReaderMode mode) {
    AppPreferences.mangaReaderMode = mode;
    state = mode;
  }
}

@Riverpod(keepAlive: true)
class MangaReaderAutoCropSettings extends _$MangaReaderAutoCropSettings {
  @override
  bool build() {
    return AppPreferences.mangaReaderAutoCrop;
  }

  void toggle(bool enabled) {
    AppPreferences.mangaReaderAutoCrop = enabled;
    state = enabled;
  }
}

@Riverpod(keepAlive: true)
class ContentLanguageSettings extends _$ContentLanguageSettings {
  @override
  Set<ContentLanguage> build() {
    final langs = AppPreferences.selectedContentLanguage;
    if (langs != null) {
      return langs;
    }

    if (platformLang == ContentLanguage.en) {
      return {ContentLanguage.en};
    }

    return ContentLanguage.values.toSet();
  }

  void toggleLanguage(ContentLanguage lang) {
    final newLanuages = state.toggle(lang);
    state = newLanuages;
    AppPreferences.selectedContentLanguage = newLanuages;
  }

  static ContentLanguage? get platformLang {
    final [localeLang, ...] = Platform.localeName.split("_");
    return ContentLanguage.values
        .where((lang) => lang.name == localeLang)
        .firstOrNull;
  }
}

@Riverpod(keepAlive: true)
class OfflineStorageDirectory extends _$OfflineStorageDirectory {
  @override
  String? build() {
    return AppPreferences.offlineDownloadsDirectory;
  }

  void select(String? path) {
    AppPreferences.offlineDownloadsDirectory = path;
    state = path;
    OfflineStorage().init();
  }
}
