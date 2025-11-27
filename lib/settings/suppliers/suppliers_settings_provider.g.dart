// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SuppliersSettings)
const suppliersSettingsProvider = SuppliersSettingsProvider._();

final class SuppliersSettingsProvider
    extends $NotifierProvider<SuppliersSettings, SuppliersSettingsModel> {
  const SuppliersSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suppliersSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suppliersSettingsHash();

  @$internal
  @override
  SuppliersSettings create() => SuppliersSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SuppliersSettingsModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SuppliersSettingsModel>(value),
    );
  }
}

String _$suppliersSettingsHash() => r'11b82c203b8f917db0e2d695af61416fb450cd4e';

abstract class _$SuppliersSettings extends $Notifier<SuppliersSettingsModel> {
  SuppliersSettingsModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<SuppliersSettingsModel, SuppliersSettingsModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SuppliersSettingsModel, SuppliersSettingsModel>,
              SuppliersSettingsModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(enabledSuppliers)
const enabledSuppliersProvider = EnabledSuppliersProvider._();

final class EnabledSuppliersProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  const EnabledSuppliersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enabledSuppliersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enabledSuppliersHash();

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    return enabledSuppliers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$enabledSuppliersHash() => r'00803c2a340060d8ed40af06f0ca991945656505';
