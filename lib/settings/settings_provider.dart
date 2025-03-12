import 'package:content_suppliers_api/model.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/utils/collections.dart';

part 'settings_provider.g.dart';

@riverpod
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

@riverpod
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

@riverpod
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

@riverpod
class MangaReaderScaleSettings extends _$MangaReaderScaleSettings {
  @override
  MangaReaderScale build() {
    return AppPreferences.mangaReaderScale;
  }

  void select(MangaReaderScale scale) {
    AppPreferences.mangaReaderScale = scale;
    state = scale;
  }
}

@riverpod
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

@riverpod
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

@riverpod
class ContentLanguageSettings extends _$ContentLanguageSettings {
  @override
  Set<ContentLanguage> build() {
    return AppPreferences.selectedContentLanguage ??
        ContentLanguage.values.toSet();
  }

  void toggleLanguage(ContentLanguage lang) {
    final newLanuages = state.toggle(lang);
    state = newLanuages;
    AppPreferences.selectedContentLanguage = newLanuages;
  }
}
