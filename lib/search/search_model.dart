import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class SearchState extends Equatable {
  final Map<String, List<ContentInfo>> results;
  final bool isLoading;

  const SearchState({
    this.results = const {},
    required this.isLoading,
  });

  static const SearchState empty = SearchState(results: {}, isLoading: false);

  const SearchState.loading()
      : isLoading = true,
        results = const {};

  SearchState addResults(
    String supplierName,
    List<ContentInfo> supplierResults,
  ) {
    return copyWith(results: {...results, supplierName: supplierResults});
  }

  SearchState copyWith({
    Map<String, List<ContentInfo>>? results,
    bool? isLoading,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [results, isLoading];
}
