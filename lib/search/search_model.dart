import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

@immutable
class SuppliersSearchResults {
  final bool hasMore;
  final bool isLoading;
  final List<ContentInfo> results;
  final int page;

  const SuppliersSearchResults({
    this.hasMore = false,
    this.isLoading = false,
    this.results = const [],
    this.page = 0,
  });

  factory SuppliersSearchResults.loadingNew() {
    return SuppliersSearchResults(
      isLoading: false,
      hasMore: true,
      results: [],
      page: 0,
    );
  }

  SuppliersSearchResults addPage(List<ContentInfo> supplierResults, int page) {
    if (supplierResults.isEmpty) {
      return copyWith(hasMore: false, isLoading: false);
    }

    return copyWith(
      results: [...results, ...supplierResults],
      page: page,
      isLoading: false,
    );
  }

  SuppliersSearchResults copyWith({
    bool? hasMore,
    bool? isLoading,
    List<ContentInfo>? results,
    int? page,
  }) {
    return SuppliersSearchResults(
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      page: page ?? this.page,
    );
  }

  bool get hasResults => results.isNotEmpty;
}

@immutable
class SearchState {
  final String? query;
  final bool isLoading;
  final bool isDone;
  final Set<String> suppliers;
  final bool hasResults;
  final Map<String, SuppliersSearchResults> supplierResults;

  const SearchState({
    this.query,
    this.isLoading = false,
    this.isDone = false,
    this.suppliers = const {},
    this.hasResults = false,
    this.supplierResults = const {},
  });

  static const SearchState empty = SearchState();

  const SearchState.loading(this.query, this.suppliers)
    : isLoading = true,
      hasResults = true,
      isDone = false,
      supplierResults = const {};

  SearchState done(bool hasResults) {
    return copyWith(isLoading: false, isDone: true, hasResults: hasResults);
  }

  SearchState copyWith({
    String? query,
    bool? isLoading,
    bool? isDone,
    Set<String>? suppliers,
    bool? hasResults,
    Map<String, SuppliersSearchResults>? supplierResults,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isDone: isDone ?? this.isDone,
      suppliers: suppliers ?? this.suppliers,
      hasResults: hasResults ?? this.hasResults,
      supplierResults: supplierResults ?? this.supplierResults,
    );
  }

  SearchState setSupplierResults(String name, SuppliersSearchResults value) {
    final newMap = Map<String, SuppliersSearchResults>.from(supplierResults);
    newMap[name] = value;
    return copyWith(supplierResults: newMap);
  }
}
