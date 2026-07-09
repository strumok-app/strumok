import 'package:strumok/app_preferences.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/search/search_model.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/collections.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/utils/trace.dart';

part 'search_provider.g.dart';

@riverpod
Set<String> enabledSearchSuppliersNames(Ref ref) {
  final enabledSuppliers = ref.watch(enabledSuppliersProvider);
  final searchSettings = ref.watch(searchSettingsProvider);
  return enabledSuppliers.intersection(searchSettings.searchSuppliersNames);
}

@Riverpod(keepAlive: true)
class Search extends _$Search {
  @override
  SearchState build() => SearchState.empty;

  Future<void> search(String query) async {
    query = cleanupQuery(query);

    if (query.isEmpty) {
      return;
    }

    final contentSuppliers = ref.read(enabledSearchSuppliersNamesProvider);

    state = SearchState.loading(query, contentSuppliers);

    final futures = contentSuppliers
        .map((suppliersName) => _searchSupplierInitial(suppliersName, query))
        .toList();

    final results = await Future.wait(futures);

    final hasResults = results.any((r) => r.hasResults);

    state = state.done(hasResults);
  }

  Future<SuppliersSearchResults> _searchSupplierInitial(
    String supplierName,
    String query,
  ) async {
    final init = SuppliersSearchResults.loadingNew();
    state = state.setSupplierResults(supplierName, init);

    try {
      final supplierResults = await ContentSuppliers().search(
        supplierName,
        query,
        1,
      );

      final updated = init.addPage(supplierResults, 1);
      state = state.setSupplierResults(supplierName, updated);
      return updated;
    } catch (e, stackTrace) {
      traceError(
        error: e,
        stackTrace: stackTrace,
        message: "Failed to load search results: $supplierName $query",
      );
      final updated = init.copyWith(isLoading: false, hasMore: false);
      state = state.setSupplierResults(supplierName, updated);
      return updated;
    }
  }

  Future<List<ContentInfo>> loadNext(String supplierName) async {
    final current =
        state.supplierResults[supplierName] ??
        SuppliersSearchResults.loadingNew();

    if (!current.hasMore || current.isLoading || state.query == null) {
      return [];
    }

    logger.info("Loading search results: ${supplierName} ${state.query}");

    state = state.setSupplierResults(
      supplierName,
      current.copyWith(isLoading: true),
    );

    final page = current.page + 1;
    try {
      final supplierResults = await ContentSuppliers().search(
        supplierName,
        state.query!,
        page,
      );

      logger.info(
        "Loaded search results: ${supplierResults.length} for ${supplierName} ${state.query}",
      );

      final updated = current.addPage(supplierResults, page);
      state = state.setSupplierResults(supplierName, updated);

      return supplierResults;
    } catch (e, stackTrace) {
      traceError(
        error: e,
        stackTrace: stackTrace,
        message:
            "Failed to load search results: ${supplierName} ${state.query}",
      );
      state = state.setSupplierResults(
        supplierName,
        current.copyWith(isLoading: false, hasMore: false),
      );
      return [];
    }
  }
}

@immutable
class SearchSettingsModel extends Equatable {
  final Set<ContentLanguage> languages;
  final Set<ContentType> types;
  final Set<String> suppliersNames;

  const SearchSettingsModel({
    required this.languages,
    required this.types,
    required this.suppliersNames,
  });

  Set<String> get avaliableSuppliers {
    return ContentSuppliers().suppliers
        .where(
          (sup) =>
              languages.intersection(sup.supportedLanguages).isNotEmpty &&
              types.intersection(sup.supportedTypes).isNotEmpty,
        )
        .map((sup) => sup.name)
        .toSet();
  }

  Set<String> get searchSuppliersNames =>
      suppliersNames.intersection(avaliableSuppliers);

  @override
  List<Object?> get props => [languages, types, suppliersNames];

  SearchSettingsModel copyWith({
    Set<ContentLanguage>? languages,
    Set<ContentType>? types,
    Set<String>? suppliersNames,
  }) {
    return SearchSettingsModel(
      languages: languages ?? this.languages,
      types: types ?? this.types,
      suppliersNames: suppliersNames ?? this.suppliersNames,
    );
  }
}

@riverpod
class SearchSettings extends _$SearchSettings {
  @override
  SearchSettingsModel build() {
    return SearchSettingsModel(
      languages:
          AppPreferences.selectedContentLanguage ??
          ContentLanguage.values.toSet(),
      types: AppPreferences.searchContentType ?? ContentType.values.toSet(),
      suppliersNames:
          AppPreferences.searchContentSuppliers ??
          ContentSuppliers().suppliersName,
    );
  }

  void toggleLanguage(ContentLanguage lang) {
    final newLanuages = state.languages.toggle(lang);
    state = state.copyWith(languages: newLanuages);
    AppPreferences.selectedContentLanguage = newLanuages;
  }

  void toggleType(ContentType type) {
    final newTypes = state.types.toggle(type);
    state = state.copyWith(types: newTypes);
    AppPreferences.searchContentType = newTypes;
  }

  void toggleSupplierName(String supplierName) {
    final newSupplierNames = state.suppliersNames.toggle(supplierName);
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.searchContentSuppliers = newSupplierNames;
  }

  void toggleAllSuppliers(bool select) {
    final newSupplierNames = select
        ? ContentSuppliers().suppliersName
        : <String>{};
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.searchContentSuppliers = newSupplierNames;
  }
}
