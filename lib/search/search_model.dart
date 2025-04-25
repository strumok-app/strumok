import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

@immutable
class SuppliersSearchResults {
  final String supplierName;
  final String? query;
  final bool hasMore;
  final bool isLoading;
  final List<ContentInfo> results;
  final int page;

  const SuppliersSearchResults({
    required this.supplierName,
    this.query,
    this.hasMore = false,
    this.isLoading = false,
    this.results = const [],
    this.page = 1,
  });

  SuppliersSearchResults loadingNew(String query) {
    return copyWith(
      isLoading: true,
      query: query,
      hasMore: true,
      results: [],
      page: 1,
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
    String? query,
    bool? isLoading,
    List<ContentInfo>? results,
    int? page,
  }) {
    return SuppliersSearchResults(
      supplierName: supplierName,
      query: query ?? this.query,
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
  final bool isLoading;
  final bool isDone;
  final Set<String> suppliers;
  final bool hasResults;

  const SearchState({
    this.isLoading = false,
    this.isDone = false,
    this.suppliers = const {},
    this.hasResults = false,
  });

  static const SearchState empty = SearchState();

  const SearchState.loading(this.suppliers)
    : isLoading = true,
      hasResults = true,
      isDone = false;

  SearchState done(bool hasResults) {
    return SearchState(
      isLoading: false,
      hasResults: hasResults,
      isDone: true,
      suppliers: suppliers,
    );
  }
}
