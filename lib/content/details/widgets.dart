import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/collection/widgets/priority_selector.dart';
import 'package:strumok/collection/widgets/status_selector.dart';

class MediaCollectionItemButtons extends ConsumerWidget {
  MediaCollectionItemButtons({super.key, required ContentDetails contentDetails})
      : provider = collectionItemProvider(contentDetails);

  final CollectionItemProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ref.watch(provider).maybeWhen(
            data: (data) => _render(context, ref, data),
            orElse: () => const SizedBox(height: 40),
          ),
    );
  }

  Widget _render(
    BuildContext context,
    WidgetRef ref,
    MediaCollectionItem data,
  ) {
    return Row(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          width: 200,
          child: CollectionItemStatusSelector.button(
            collectionItem: data,
            onSelect: (status) {
              ref.read(provider.notifier).setStatus(status);
            },
          ),
        ),
        const SizedBox(width: 8),
        if (data.status != MediaCollectionItemStatus.none)
          CollectionItemPrioritySelector(
            collectionItem: data,
            onSelect: (priority) {
              ref.read(provider.notifier).setPriority(priority);
            },
          )
      ],
    );
  }
}
