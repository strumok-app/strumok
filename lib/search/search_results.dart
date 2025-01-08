import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/search/search_model.dart';
import 'package:strumok/widgets/horizontal_list.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchResults extends HookWidget {
  final SearchState searchState;
  const SearchResults({super.key, required this.searchState});

  @override
  Widget build(BuildContext context) {
    final suppliersWithResult =
        searchState.results.entries.where((r) => r.value.isNotEmpty);

    if (!searchState.isLoading && suppliersWithResult.isEmpty) {
      // no result
      return Center(
        child: Text(
          AppLocalizations.of(context)!.searchNoResults,
        ),
      );
    }

    // loading providers
    return ListView(
      children: [
        ...suppliersWithResult.map(
          (e) => _renderSupplierResults(context, e.key, e.value),
        ),
      ],
    );
  }

  Widget _renderSupplierResults(
      BuildContext context, String key, List<ContentInfo> value) {
    return HorizontalList(
      title: Text(
        key,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      itemBuilder: (context, index) {
        final item = value[index];

        return ContentInfoCard(
          contentInfo: item,
          showSupplier: false,
        );
      },
      itemCount: value.length,
    );
  }
}
