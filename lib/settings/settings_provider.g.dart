// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OfflineMode)
const offlineModeProvider = OfflineModeProvider._();

final class OfflineModeProvider extends $NotifierProvider<OfflineMode, bool> {
  const OfflineModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineModeHash();

  @$internal
  @override
  OfflineMode create() => OfflineMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$offlineModeHash() => r'2b153b9eb232d3a35e915c0baf32d94e63b4b922';

abstract class _$OfflineMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(BrightnessSetting)
const brightnessSettingProvider = BrightnessSettingProvider._();

final class BrightnessSettingProvider
    extends $NotifierProvider<BrightnessSetting, Brightness?> {
  const BrightnessSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brightnessSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brightnessSettingHash();

  @$internal
  @override
  BrightnessSetting create() => BrightnessSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Brightness? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Brightness?>(value),
    );
  }
}

String _$brightnessSettingHash() => r'b8dc23c545ba547ed6a9ee9b1f98c25844f77f72';

abstract class _$BrightnessSetting extends $Notifier<Brightness?> {
  Brightness? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Brightness?, Brightness?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Brightness?, Brightness?>,
              Brightness?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ColorSettings)
const colorSettingsProvider = ColorSettingsProvider._();

final class ColorSettingsProvider
    extends $NotifierProvider<ColorSettings, Color> {
  const ColorSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorSettingsHash();

  @$internal
  @override
  ColorSettings create() => ColorSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color>(value),
    );
  }
}

String _$colorSettingsHash() => r'c267c017ab86c9e61c35f6538e707141d424e757';

abstract class _$ColorSettings extends $Notifier<Color> {
  Color build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Color, Color>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Color, Color>,
              Color,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserLanguageSetting)
const userLanguageSettingProvider = UserLanguageSettingProvider._();

final class UserLanguageSettingProvider
    extends $NotifierProvider<UserLanguageSetting, String> {
  const UserLanguageSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userLanguageSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userLanguageSettingHash();

  @$internal
  @override
  UserLanguageSetting create() => UserLanguageSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userLanguageSettingHash() =>
    r'91050b4367d8528cf709daf485d17425730a1db5';

abstract class _$UserLanguageSetting extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MangaReaderBackgroundSettings)
const mangaReaderBackgroundSettingsProvider =
    MangaReaderBackgroundSettingsProvider._();

final class MangaReaderBackgroundSettingsProvider
    extends
        $NotifierProvider<
          MangaReaderBackgroundSettings,
          MangaReaderBackground
        > {
  const MangaReaderBackgroundSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mangaReaderBackgroundSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mangaReaderBackgroundSettingsHash();

  @$internal
  @override
  MangaReaderBackgroundSettings create() => MangaReaderBackgroundSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MangaReaderBackground value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MangaReaderBackground>(value),
    );
  }
}

String _$mangaReaderBackgroundSettingsHash() =>
    r'29692529e488bbd124e0779ea4798145d70bb44a';

abstract class _$MangaReaderBackgroundSettings
    extends $Notifier<MangaReaderBackground> {
  MangaReaderBackground build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MangaReaderBackground, MangaReaderBackground>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MangaReaderBackground, MangaReaderBackground>,
              MangaReaderBackground,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MangaReaderModeSettings)
const mangaReaderModeSettingsProvider = MangaReaderModeSettingsProvider._();

final class MangaReaderModeSettingsProvider
    extends $NotifierProvider<MangaReaderModeSettings, MangaReaderMode> {
  const MangaReaderModeSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mangaReaderModeSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mangaReaderModeSettingsHash();

  @$internal
  @override
  MangaReaderModeSettings create() => MangaReaderModeSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MangaReaderMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MangaReaderMode>(value),
    );
  }
}

String _$mangaReaderModeSettingsHash() =>
    r'653c4c5287f7318462ed0ea35971f87e5f7c16a2';

abstract class _$MangaReaderModeSettings extends $Notifier<MangaReaderMode> {
  MangaReaderMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MangaReaderMode, MangaReaderMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MangaReaderMode, MangaReaderMode>,
              MangaReaderMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MangaReaderAutoCropSettings)
const mangaReaderAutoCropSettingsProvider =
    MangaReaderAutoCropSettingsProvider._();

final class MangaReaderAutoCropSettingsProvider
    extends $NotifierProvider<MangaReaderAutoCropSettings, bool> {
  const MangaReaderAutoCropSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mangaReaderAutoCropSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mangaReaderAutoCropSettingsHash();

  @$internal
  @override
  MangaReaderAutoCropSettings create() => MangaReaderAutoCropSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mangaReaderAutoCropSettingsHash() =>
    r'08e6eb853cc1f757406b18253389a9e453fbdb7e';

abstract class _$MangaReaderAutoCropSettings extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ContentLanguageSettings)
const contentLanguageSettingsProvider = ContentLanguageSettingsProvider._();

final class ContentLanguageSettingsProvider
    extends $NotifierProvider<ContentLanguageSettings, Set<ContentLanguage>> {
  const ContentLanguageSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentLanguageSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentLanguageSettingsHash();

  @$internal
  @override
  ContentLanguageSettings create() => ContentLanguageSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<ContentLanguage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<ContentLanguage>>(value),
    );
  }
}

String _$contentLanguageSettingsHash() =>
    r'd17ebea44c40c66ee4f193315902bd1ecc658e2f';

abstract class _$ContentLanguageSettings
    extends $Notifier<Set<ContentLanguage>> {
  Set<ContentLanguage> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<ContentLanguage>, Set<ContentLanguage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<ContentLanguage>, Set<ContentLanguage>>,
              Set<ContentLanguage>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
