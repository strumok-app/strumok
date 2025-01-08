// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchHash() => r'dd5bbe25ed92804f269717d138a7b401fc7cebd5';

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
String _$searchSettingsHash() => r'8e991a8b78a7ed7a41e5a4129b476780d0733e79';

/// See also [SearchSettings].
@ProviderFor(SearchSettings)
final searchSettingsProvider =
    AutoDisposeNotifierProvider<SearchSettings, SearchSettingsModel>.internal(
  SearchSettings.new,
  name: r'searchSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchSettings = AutoDisposeNotifier<SearchSettingsModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
