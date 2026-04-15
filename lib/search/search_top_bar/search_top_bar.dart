import 'package:strumok/search/ai_search/ai_search_button.dart';
import 'package:strumok/search/search_provider.dart';
import 'package:strumok/search/search_top_bar/filters_dialog.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_model.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_provider.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchTopBar extends StatefulWidget {
  const SearchTopBar({super.key});

  @override
  State<SearchTopBar> createState() => _SearchTopBarState();
}

class _SearchTopBarState extends State<SearchTopBar> {
  final searchController = SearchController();
  final searchBarFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchBarFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchBarFocusNode.requestFocus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: TVDetector.isTV
                      ? Alignment.centerLeft
                      : Alignment.center,
                  child: _SearchBar(
                    searchController: searchController,
                    focusNode: searchBarFocusNode,
                  ),
                ),
              ),
              if (TVDetector.isTV)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FiltersButton(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends ConsumerWidget {
  final SearchController searchController;
  final FocusNode focusNode;

  const _SearchBar({required this.searchController, required this.focusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingResults = ref.watch(searchProvider).isLoading;
    final offlineMode = ref.watch(offlineModeProvider);

    return SearchAnchor(
      enabled: !offlineMode,
      dividerColor: Colors.transparent,
      isFullScreen: isMobile(context),
      searchController: searchController,
      viewOnChanged: (value) {
        ref.read(suggestionsProvider.notifier).suggest(value);
      },
      viewOnSubmitted: (value) {
        _search(ref, value);
        if (searchController.isOpen) {
          searchController.closeView(value);
        }
      },
      builder: (context, controller) {
        return BackButtonListener(
          onBackButtonPressed: () async {
            if (focusNode.hasFocus) {
              focusNode.previousFocus();
              return true;
            }
            return false;
          },
          child: SearchBar(
            focusNode: offlineMode ? null : focusNode,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.only(left: 16.0, right: 8.0),
            ),
            leading: _buildLeading(isLoadingResults),
            controller: controller,
            onTap: () => controller.openView(),
            onChanged: (value) => controller.openView(),
            onSubmitted: (value) => _search(ref, value),
            trailing: TVDetector.isTV
                ? null
                : [const AISearchButton(), FiltersButton()],
          ),
        );
      },
      viewBuilder: (suggestions) => _TopSearchSuggestions(
        searchController: searchController,
        onSelect: (value) => _search(ref, value),
      ),
      suggestionsBuilder: (context, controller) => [],
    );
  }

  Widget _buildLeading(bool isLoadingResults) {
    return isLoadingResults
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          )
        : const Icon(Icons.search);
  }

  void _search(WidgetRef ref, String query) async {
    ref.read(suggestionsProvider.notifier).addSuggestion(query);

    final searchProviderNotifier = ref.read(searchProvider.notifier);

    query = cleanupQuery(query);

    if (query.isEmpty) {
      return;
    }

    final contentSuppliers = ref.read(enabledSearchSuppliersNamesProvider);

    for (final suppliersName in contentSuppliers) {
      // eagerly init all search providers
      ref.watch(supplierSearchProvider(suppliersName));
    }

    bool hasResults = false;
    final stream = Stream.fromFutures(
      contentSuppliers.map(
        (suppliersName) => ref
            .read(supplierSearchProvider(suppliersName).notifier)
            .search(query),
      ),
    );

    searchProviderNotifier.loading(contentSuppliers);

    await for (final supplierResults in stream) {
      if (supplierResults.isNotEmpty) {
        hasResults = true;
      }
    }

    searchProviderNotifier.done(hasResults);
  }
}

class _TopSearchSuggestions extends ConsumerWidget {
  const _TopSearchSuggestions({
    required this.searchController,
    required this.onSelect,
  });

  final SearchController searchController;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsValue = ref.watch(suggestionsProvider);

    return suggestionsValue.maybeWhen(
      data: (suggestions) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView(
            children: suggestions
                .map((suggestion) => _renderSuggestion(suggestion, ref))
                .toList(),
          ),
        );
      },
      orElse: () => ListView(),
    );
  }

  Widget _renderSuggestion(SearchSuggestion suggestion, WidgetRef ref) {
    return Stack(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 16.0, right: 56.0),
          title: Text(suggestion.text),
          onTap: () {
            onSelect(suggestion.text);
            searchController.closeView(suggestion.text);
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref
                    .read(suggestionsProvider.notifier)
                    .deleteSuggestion(suggestion);
              },
            ),
          ),
        ),
      ],
    );
  }
}
