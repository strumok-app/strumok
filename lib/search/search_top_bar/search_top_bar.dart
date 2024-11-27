import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/search/search_provider.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_model.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_provider.dart';
import 'package:strumok/settings/suppliers/suppliers_settings_provider.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/filter_dialog_section.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final searchBarFocusNode = FocusNode();
// final searchController = SearchController();

// @override
// void initState() {
//   super.initState();

//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     searchBarFocusNode.requestFocus();
//   });

//   searchController.text = ref.read(searchProvider).query ?? "";
// }

// @override
// void dispose() {
//   super.dispose();
//   searchBarFocusNode.dispose();
//   searchController.dispose();
// }

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

      searchController.text = ref.read(searchProvider).query ?? "";
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
                  child: _renderSearchBar(
                    searchController,
                    searchBarFocusNode,
                    context,
                    ref,
                  ),
                ),
              ),
              if (TVDetector.isTV)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _renderFilterSwitcher(context),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderSearchBar(
    SearchController searchController,
    FocusNode searchBarFocusNode,
    BuildContext context,
    WidgetRef ref,
  ) {
    return SearchAnchor(
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
            if (searchBarFocusNode.hasFocus) {
              searchBarFocusNode.previousFocus();
              return true;
            }
            return false;
          },
          child: SearchBar(
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.only(left: 16.0, right: 8.0),
            ),
            focusNode: searchBarFocusNode,
            leading: const Icon(Icons.search),
            controller: controller,
            onTap: () {
              controller.openView();
            },
            onChanged: (value) {
              controller.openView();
            },
            onSubmitted: (value) {
              _search(ref, value);
            },
            trailing: TVDetector.isTV ? null : [_renderFilterSwitcher(context)],
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

  void _search(WidgetRef ref, String query) {
    ref.read(searchProvider.notifier).search(query);
    ref.read(suggestionsProvider.notifier).addSuggestion(query);
  }

  IconButton _renderFilterSwitcher(BuildContext context) {
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
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FilterDialogSection(
              label: Text(
                AppLocalizations.of(context)!.language,
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
                    ref.read(searchSettingsProvider.notifier).toggleType(item);
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
                  selected: searchSettings.searchSuppliersNames.contains(item),
                  onSelected: searchSettings.avaliableSuppliers.contains(item)
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
    );
  }
}

class _TopSearchSuggestions extends HookConsumerWidget {
  const _TopSearchSuggestions(
      {required this.searchController, required this.onSelect});

  final SearchController searchController;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsValue = ref.watch(suggestionsProvider);

    return suggestionsValue.maybeWhen(
      data: (suggestions) {
        return ListView(
          children: suggestions
              .map((suggestion) => _renderSuggestion(suggestion, ref))
              .toList(),
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
        )
      ],
    );
  }
}
