// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enabledSuppliersHash() => r'ca65f721a09fce30d81493e6c3ccfd8fab248cb8';

/// See also [enabledSuppliers].
@ProviderFor(enabledSuppliers)
final enabledSuppliersProvider = Provider<Set<String>>.internal(
  enabledSuppliers,
  name: r'enabledSuppliersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$enabledSuppliersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EnabledSuppliersRef = ProviderRef<Set<String>>;
String _$suppliersSettingsHash() => r'5896c1396410404f7ee16ecde5a7537d4fefd85e';

/// See also [SuppliersSettings].
@ProviderFor(SuppliersSettings)
final suppliersSettingsProvider =
    NotifierProvider<SuppliersSettings, SuppliersSettingsModel>.internal(
  SuppliersSettings.new,
  name: r'suppliersSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$suppliersSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SuppliersSettings = Notifier<SuppliersSettingsModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
