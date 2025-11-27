// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(enabledSearchSuppliersNames)
const enabledSearchSuppliersNamesProvider =
    EnabledSearchSuppliersNamesProvider._();

final class EnabledSearchSuppliersNamesProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  const EnabledSearchSuppliersNamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enabledSearchSuppliersNamesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enabledSearchSuppliersNamesHash();

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    return enabledSearchSuppliersNames(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$enabledSearchSuppliersNamesHash() =>
    r'385e38a8ebd0db0c12576729777096508c4e19b9';

@ProviderFor(Search)
const searchProvider = SearchProvider._();

final class SearchProvider extends $NotifierProvider<Search, SearchState> {
  const SearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHash();

  @$internal
  @override
  Search create() => Search();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchHash() => r'41470ba87684667f9dd8198e4f0b27f2ba57364f';

abstract class _$Search extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SupplierSearch)
const supplierSearchProvider = SupplierSearchFamily._();

final class SupplierSearchProvider
    extends $NotifierProvider<SupplierSearch, SuppliersSearchResults> {
  const SupplierSearchProvider._({
    required SupplierSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'supplierSearchProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$supplierSearchHash();

  @override
  String toString() {
    return r'supplierSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SupplierSearch create() => SupplierSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SuppliersSearchResults value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SuppliersSearchResults>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$supplierSearchHash() => r'cd16397459d17cc4fbd66e69f3daaa39f19c4e3a';

final class SupplierSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          SupplierSearch,
          SuppliersSearchResults,
          SuppliersSearchResults,
          SuppliersSearchResults,
          String
        > {
  const SupplierSearchFamily._()
    : super(
        retry: null,
        name: r'supplierSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SupplierSearchProvider call(String suppliersName) =>
      SupplierSearchProvider._(argument: suppliersName, from: this);

  @override
  String toString() => r'supplierSearchProvider';
}

abstract class _$SupplierSearch extends $Notifier<SuppliersSearchResults> {
  late final _$args = ref.$arg as String;
  String get suppliersName => _$args;

  SuppliersSearchResults build(String suppliersName);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<SuppliersSearchResults, SuppliersSearchResults>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SuppliersSearchResults, SuppliersSearchResults>,
              SuppliersSearchResults,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SearchSettings)
const searchSettingsProvider = SearchSettingsProvider._();

final class SearchSettingsProvider
    extends $NotifierProvider<SearchSettings, SearchSettingsModel> {
  const SearchSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSettingsHash();

  @$internal
  @override
  SearchSettings create() => SearchSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchSettingsModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchSettingsModel>(value),
    );
  }
}

String _$searchSettingsHash() => r'7030f15b26f51cfbf0d5caeb7dfef8ffa8bf3fbe';

abstract class _$SearchSettings extends $Notifier<SearchSettingsModel> {
  SearchSettingsModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SearchSettingsModel, SearchSettingsModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchSettingsModel, SearchSettingsModel>,
              SearchSettingsModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
