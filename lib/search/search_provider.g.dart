// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(enabledSearchSuppliersNames)
final enabledSearchSuppliersNamesProvider =
    EnabledSearchSuppliersNamesProvider._();

final class EnabledSearchSuppliersNamesProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  EnabledSearchSuppliersNamesProvider._()
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
final searchProvider = SearchProvider._();

final class SearchProvider extends $NotifierProvider<Search, SearchState> {
  SearchProvider._()
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

String _$searchHash() => r'501adde69d1c03461f83c24ad49a523ddd219337';

abstract class _$Search extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchSettings)
final searchSettingsProvider = SearchSettingsProvider._();

final class SearchSettingsProvider
    extends $NotifierProvider<SearchSettings, SearchSettingsModel> {
  SearchSettingsProvider._()
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
    final ref = this.ref as $Ref<SearchSettingsModel, SearchSettingsModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchSettingsModel, SearchSettingsModel>,
              SearchSettingsModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
