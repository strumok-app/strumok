import 'package:strumok/app_preferences.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/search/search_model.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/collections.dart';
import 'package:strumok/utils/text.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

@Riverpod(keepAlive: true)
class Search extends _$Search {
  @override
  SearchState build() => SearchState.empty;

  void search(String query) async {
    final text = cleanupQuery(query);

    if (text.isEmpty) {
      return;
    }

    state = const SearchState.loading();

    final enabledSuppliers = ref.read(enabledSuppliersProvider);
    final searchSettings = ref.read(searchSettingsProvider);
    final contentSuppliers = enabledSuppliers.intersection(
      searchSettings.searchSuppliersNames,
    );

    final stream = ContentSuppliers().search(query, contentSuppliers);

    final subscription = stream.listen((event) {
      final (supplierName, supplierResults) = event;
      state = state.addResults(supplierName, supplierResults);
    });

    subscription.onDone(() {
      state = state.copyWith(isLoading: false);
      subscription.cancel();
    });
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
    return ContentSuppliers()
        .suppliers
        .where(
          (sup) =>
              languages.intersection(sup.supportedLanguages).isNotEmpty &&
              types.intersection(sup.supportedTypes).isNotEmpty,
        )
        .map((sup) => sup.name)
        .toSet();
  }

  Set<String> get searchSuppliersNames => suppliersNames.intersection(avaliableSuppliers);

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
        languages: AppPreferences.selectedContentLanguage ?? ContentLanguage.values.toSet(),
        types: AppPreferences.selectedContentType ?? ContentType.values.toSet(),
        suppliersNames: AppPreferences.collectionContentSuppliers ?? ContentSuppliers().suppliersName);
  }

  void toggleLanguage(ContentLanguage lang) {
    final newLanuages = state.languages.toggle(lang);
    state = state.copyWith(languages: newLanuages);
    AppPreferences.selectedContentLanguage = newLanuages;
  }

  void toggleType(ContentType type) {
    final newTypes = state.types.toggle(type);
    state = state.copyWith(types: newTypes);
    AppPreferences.selectedContentType = newTypes;
  }

  void toggleSupplierName(String supplierName) {
    final newSupplierNames = state.suppliersNames.toggle(supplierName);
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.collectionContentSuppliers = newSupplierNames;
  }

  void toggleAllSuppliers(bool select) {
    final newSupplierNames = select ? ContentSuppliers().suppliersName : <String>{};
    state = state.copyWith(suppliersNames: newSupplierNames);
    AppPreferences.collectionContentSuppliers = newSupplierNames;
  }
}
