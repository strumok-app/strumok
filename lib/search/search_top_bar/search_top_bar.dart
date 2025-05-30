import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/search/search_provider.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_model.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_provider.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/filter_dialog_section.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchTopBar extends HookConsumerWidget {
  const SearchTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useSearchController();
    final searchBarFocusNode = useFocusNode();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchBarFocusNode.requestFocus();
      });
      return null;
    }, [searchController, searchBarFocusNode]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment:
                      TVDetector.isTV ? Alignment.centerLeft : Alignment.center,
                  child: _SearchBar(
                    searchController: searchController,
                    focusNode: searchBarFocusNode,
                  ),
                ),
              ),
              if (TVDetector.isTV)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _FilterSwitcher(),
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
            trailing: TVDetector.isTV ? null : [_FilterSwitcher()],
          ),
        );
      },
      viewBuilder:
          (suggestions) => _TopSearchSuggestions(
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

class _FilterSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const _FilterSelectorsDialog(),
        );
      },
      icon: const Icon(Icons.tune),
    );
  }
}

class _FilterSelectorsDialog extends ConsumerWidget {
  const _FilterSelectorsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabledSuppliers = ref.watch(enabledSuppliersProvider).toList();
    final searchSettings = ref.watch(searchSettingsProvider);

    return Dialog(
      insetPadding: EdgeInsets.only(left: isMobile(context) ? 0 : 80.0),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FilterDialogSection(
                label: Text(
                  AppLocalizations.of(context)!.contentLanguage,
                  style: theme.textTheme.headlineSmall,
                ),
                itemsCount: ContentLanguage.values.length,
                itemBuilder: (context, index) {
                  final item = ContentLanguage.values[index];
                  return FilterChip(
                    selected: searchSettings.languages.contains(item),
                    label: Text(item.label),
                    onSelected: (value) {
                      ref
                          .read(searchSettingsProvider.notifier)
                          .toggleLanguage(item);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              FilterDialogSection(
                label: Text(
                  AppLocalizations.of(context)!.contentType,
                  style: theme.textTheme.headlineSmall,
                ),
                itemsCount: ContentType.values.length,
                itemBuilder: (context, index) {
                  final item = ContentType.values[index];
                  return FilterChip(
                    selected: searchSettings.types.contains(item),
                    label: Text(contentTypeLabel(context, item)),
                    onSelected: (value) {
                      ref
                          .read(searchSettingsProvider.notifier)
                          .toggleType(item);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              FilterDialogSection(
                label: Text(
                  AppLocalizations.of(context)!.suppliers,
                  style: theme.textTheme.headlineSmall,
                ),
                itemsCount: enabledSuppliers.length,
                itemBuilder: (context, index) {
                  final item = enabledSuppliers[index];
                  return FilterChip(
                    label: Text(item),
                    selected: searchSettings.searchSuppliersNames.contains(
                      item,
                    ),
                    onSelected:
                        searchSettings.avaliableSuppliers.contains(item)
                            ? (value) {
                              ref
                                  .read(searchSettingsProvider.notifier)
                                  .toggleSupplierName(item);
                            }
                            : null,
                  );
                },
                onSelectAll: () {
                  ref
                      .read(searchSettingsProvider.notifier)
                      .toggleAllSuppliers(true);
                },
                onUnselectAll: () {
                  ref
                      .read(searchSettingsProvider.notifier)
                      .toggleAllSuppliers(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopSearchSuggestions extends HookConsumerWidget {
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
            children:
                suggestions
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
