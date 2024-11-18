import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/utils/android_tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:strumok/widgets/filter_dialog_section.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CollectionTopBar extends HookConsumerWidget {
  const CollectionTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(
      text: ref.read(collectionFilterQueryProvider),
    );

    return Column(
      children: [
        _renderSearchBar(context, ref, controller),
      ],
    );
  }

  Widget _renderSearchBar(
      BuildContext context, WidgetRef ref, TextEditingController controller) {
    final searchBarFocusNode = useFocusNode();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: BackButtonListener(
                onBackButtonPressed: () async {
                  if (searchBarFocusNode.hasFocus) {
                    searchBarFocusNode.unfocus();
                    return true;
                  }
                  return false;
                },
                child: SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.only(left: 16.0, right: 8.0),
                  ),
                  focusNode: searchBarFocusNode,
                  leading: const Icon(Icons.search),
                  trailing: AndroidTVDetector.isTV
                      ? null
                      : [_renderFilterSwitcher(context)],
                  onSubmitted: (value) {
                    ref.read(collectionFilterQueryProvider.notifier).state =
                        value;
                    searchBarFocusNode.requestFocus();
                  },
                ),
              ),
            ),
          ),
          if (AndroidTVDetector.isTV)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _renderFilterSwitcher(context),
            ),
        ],
      ),
    );
  }

  IconButton _renderFilterSwitcher(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
            context: context, builder: (context) => _StatusFilterDialog());
      },
      icon: const Icon(Icons.tune),
    );
  }
}

class _StatusFilterDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionFilter = ref.watch(collectionFilterProvider);
    final suppliersNames = ContentSuppliers.instance.suppliersName.toList();
    final allStatus = MediaCollectionItemStatus.values
        .where((s) => s != MediaCollectionItemStatus.none)
        .toList();

    return Dialog(
      insetPadding: EdgeInsets.only(left: isMobile(context) ? 0 : 80.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterDialogSection(
              label: Text(
                AppLocalizations.of(context)!.mediaType,
                style: theme.textTheme.headlineSmall,
              ),
              itemsCount: MediaType.values.length,
              itemBuilder: (context, index) {
                final item = MediaType.values[index];
                return FilterChip(
                  selected: collectionFilter.mediaTypes.contains(item),
                  label: Text(mediaTypeLabel(context, item)),
                  onSelected: (value) {
                    ref
                        .read(collectionFilterProvider.notifier)
                        .toggleMediaType(item);
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            FilterDialogSection(
              label: Text(
                AppLocalizations.of(context)!.status,
                style: theme.textTheme.headlineSmall,
              ),
              itemsCount: allStatus.length,
              itemBuilder: (context, index) {
                final item = allStatus[index];
                return FilterChip(
                  selected: collectionFilter.status.contains(item),
                  label: Text(statusLabel(context, item)),
                  onSelected: (value) {
                    ref
                        .read(collectionFilterProvider.notifier)
                        .toggleStatus(item);
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
              itemsCount: suppliersNames.length,
              itemBuilder: (context, index) {
                final item = suppliersNames[index];
                return FilterChip(
                  label: Text(item),
                  selected: collectionFilter.suppliersNames.contains(item),
                  onSelected: (value) {
                    ref
                        .read(collectionFilterProvider.notifier)
                        .toggleSupplierName(item);
                  },
                );
              },
              onSelectAll: () {
                ref
                    .read(collectionFilterProvider.notifier)
                    .toggleAllSuppliers(true);
              },
              onUnselectAll: () {
                ref
                    .read(collectionFilterProvider.notifier)
                    .toggleAllSuppliers(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
