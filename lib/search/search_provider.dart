import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/search/search_model.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/collections.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  void loading(Set<String> suppliers) {
    state = SearchState.loading(suppliers);
  }

  void done(bool hasResults) {
    state = state.done(hasResults);
  }
}

@Riverpod(keepAlive: true)
class SupplierSearch extends _$SupplierSearch {
  @override
  SuppliersSearchResults build(String suppliersName) {
    return SuppliersSearchResults(supplierName: suppliersName);
  }

  Future<List<ContentInfo>> search(String query) async {
    state = state.loadingNew(query);

    final page = 1;
    final supplierResults = await ContentSuppliers().search(
      state.supplierName,
      query,
      page,
    );

    state = state.addPage(supplierResults, page);

    return supplierResults;
  }

  void loadNext() async {
    if (!state.hasMore || state.query == null) {
      return;
    }

    final page = state.page + 1;
    final supplierResults = await ContentSuppliers().search(
      state.supplierName,
      state.query!,
      page,
    );

    state = state.addPage(supplierResults, page);
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
    final newSupplierNames =
        select ? ContentSuppliers().suppliersName : <String>{};
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.searchContentSuppliers = newSupplierNames;
  }
}
