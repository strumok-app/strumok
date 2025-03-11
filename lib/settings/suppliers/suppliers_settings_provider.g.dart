// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enabledSuppliersHash() => r'00803c2a340060d8ed40af06f0ca991945656505';

/// See also [enabledSuppliers].
@ProviderFor(enabledSuppliers)
final enabledSuppliersProvider = Provider<Set<String>>.internal(
  enabledSuppliers,
  name: r'enabledSuppliersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$enabledSuppliersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnabledSuppliersRef = ProviderRef<Set<String>>;
String _$suppliersSettingsHash() => r'f6eea4ef7316f564919d011265cb1e158c180ce9';

/// See also [SuppliersSettings].
@ProviderFor(SuppliersSettings)
final suppliersSettingsProvider =
    NotifierProvider<SuppliersSettings, SuppliersSettingsModel>.internal(
      SuppliersSettings.new,
      name: r'suppliersSettingsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$suppliersSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SuppliersSettings = Notifier<SuppliersSettingsModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
