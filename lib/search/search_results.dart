import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/search/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:strumok/widgets/load_more_list_item.dart';
import 'package:strumok/widgets/nothing_to_show.dart';

class SearchResults extends ConsumerWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    if (searchState.isDone && !searchState.hasResults) {
      // no result
      return Center(
        child: NothingToShow(
          label: Text(AppLocalizations.of(context)!.searchNoResults),
        ),
      );
    }

    // loading providers
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            searchState.suppliers
                .map((s) => SupplierSearchResultsItems(supplier: s))
                .toList(),
      ),
    );
  }
}

class SupplierSearchResultsItems extends HookConsumerWidget {
  final String supplier;

  const SupplierSearchResultsItems({super.key, required this.supplier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(supplierSearchProvider(supplier));
    final results = searchResults.results;

    if (results.isEmpty) {
      return SizedBox.shrink();
    }

    return HorizontalList(
      title: Text(supplier, style: Theme.of(context).textTheme.titleMedium),
      itemBuilder: (context, index) {
        final item = results[index];

        return ContentInfoCard(contentInfo: item, showSupplier: false);
      },
      itemCount: results.length,
      trailing:
          searchResults.hasMore
              ? LoadMoreItems(
                label: AppLocalizations.of(context)!.searchMore,
                onTap:
                    () =>
                        ref
                            .read(supplierSearchProvider(supplier).notifier)
                            .loadNext(),
                loading: searchResults.isLoading,
              )
              : null,
    );
  }
}
