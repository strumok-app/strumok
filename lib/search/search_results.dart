import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/search/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:strumok/widgets/horizontal_list.dart';
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

    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        var position = scrollController.position;
        if (position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.watch(supplierSearchProvider(supplier).notifier).loadNext();
        }
      }

      scrollController.addListener(onScroll);

      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    if (searchResults.isLoading || results.isEmpty) {
      return SizedBox.shrink();
    }

    return HorizontalList(
      scrollController: searchResults.hasMore ? scrollController : null,
      title: Text(supplier, style: Theme.of(context).textTheme.titleMedium),
      itemBuilder: (context, index) {
        final item = results[index];

        return ContentInfoCard(contentInfo: item, showSupplier: false);
      },
      itemCount: results.length,
    );
  }
}
