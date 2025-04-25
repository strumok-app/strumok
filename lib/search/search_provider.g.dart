// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enabledSearchSuppliersNamesHash() =>
    r'419c51e8a145ebc94432c4df500358882b57967e';

/// See also [enabledSearchSuppliersNames].
@ProviderFor(enabledSearchSuppliersNames)
final enabledSearchSuppliersNamesProvider =
    AutoDisposeProvider<Set<String>>.internal(
      enabledSearchSuppliersNames,
      name: r'enabledSearchSuppliersNamesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$enabledSearchSuppliersNamesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EnabledSearchSuppliersNamesRef = AutoDisposeProviderRef<Set<String>>;
String _$searchHash() => r'c33783707759628110892c722f3d8650cb4336c5';

/// See also [Search].
@ProviderFor(Search)
final searchProvider = NotifierProvider<Search, SearchState>.internal(
  Search.new,
  name: r'searchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Search = Notifier<SearchState>;
String _$supplierSearchHash() => r'f9c53a1967dc88520dae062a0307851f989e7e4b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SupplierSearch
    extends BuildlessNotifier<SuppliersSearchResults> {
  late final String suppliersName;

  SuppliersSearchResults build(String suppliersName);
}

/// See also [SupplierSearch].
@ProviderFor(SupplierSearch)
const supplierSearchProvider = SupplierSearchFamily();

/// See also [SupplierSearch].
class SupplierSearchFamily extends Family<SuppliersSearchResults> {
  /// See also [SupplierSearch].
  const SupplierSearchFamily();

  /// See also [SupplierSearch].
  SupplierSearchProvider call(String suppliersName) {
    return SupplierSearchProvider(suppliersName);
  }

  @override
  SupplierSearchProvider getProviderOverride(
    covariant SupplierSearchProvider provider,
  ) {
    return call(provider.suppliersName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'supplierSearchProvider';
}

/// See also [SupplierSearch].
class SupplierSearchProvider
    extends NotifierProviderImpl<SupplierSearch, SuppliersSearchResults> {
  /// See also [SupplierSearch].
  SupplierSearchProvider(String suppliersName)
    : this._internal(
        () => SupplierSearch()..suppliersName = suppliersName,
        from: supplierSearchProvider,
        name: r'supplierSearchProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$supplierSearchHash,
        dependencies: SupplierSearchFamily._dependencies,
        allTransitiveDependencies:
            SupplierSearchFamily._allTransitiveDependencies,
        suppliersName: suppliersName,
      );

  SupplierSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.suppliersName,
  }) : super.internal();

  final String suppliersName;

  @override
  SuppliersSearchResults runNotifierBuild(covariant SupplierSearch notifier) {
    return notifier.build(suppliersName);
  }

  @override
  Override overrideWith(SupplierSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: SupplierSearchProvider._internal(
        () => create()..suppliersName = suppliersName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        suppliersName: suppliersName,
      ),
    );
  }

  @override
  NotifierProviderElement<SupplierSearch, SuppliersSearchResults>
  createElement() {
    return _SupplierSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierSearchProvider &&
        other.suppliersName == suppliersName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, suppliersName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SupplierSearchRef on NotifierProviderRef<SuppliersSearchResults> {
  /// The parameter `suppliersName` of this provider.
  String get suppliersName;
}

class _SupplierSearchProviderElement
    extends NotifierProviderElement<SupplierSearch, SuppliersSearchResults>
    with SupplierSearchRef {
  _SupplierSearchProviderElement(super.provider);

  @override
  String get suppliersName => (origin as SupplierSearchProvider).suppliersName;
}

String _$searchSettingsHash() => r'7030f15b26f51cfbf0d5caeb7dfef8ffa8bf3fbe';

/// See also [SearchSettings].
@ProviderFor(SearchSettings)
final searchSettingsProvider =
    AutoDisposeNotifierProvider<SearchSettings, SearchSettingsModel>.internal(
      SearchSettings.new,
      name: r'searchSettingsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$searchSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchSettings = AutoDisposeNotifier<SearchSettingsModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
