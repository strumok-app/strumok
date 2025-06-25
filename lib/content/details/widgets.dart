import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/collection/widgets/priority_selector.dart';
import 'package:strumok/collection/widgets/status_selector.dart';
import 'package:strumok/content/content_info_card.dart';
import 'package:strumok/widgets/horizontal_list.dart';

class MediaCollectionItemButtons extends ConsumerWidget {
  MediaCollectionItemButtons({
    super.key,
    required ContentDetails contentDetails,
  }) : provider = collectionItemProvider(contentDetails);

  final CollectionItemProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ref
          .watch(provider)
          .maybeWhen(
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
        const SizedBox(height: 42),
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
          ),
      ],
    );
  }
}

class SimilarBlock extends StatelessWidget {
  const SimilarBlock({super.key, required this.contentDetails});

  final ContentDetails contentDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HorizontalList(
      paddings: 0,
      title: Text(
        AppLocalizations.of(context)!.recommendations,
        style: theme.textTheme.headlineSmall,
      ),
      itemBuilder:
          (context, index) => ContentInfoCard(
            contentInfo: contentDetails.similar[index],
            showSupplier: false,
          ),
      itemCount: contentDetails.similar.length,
    );
  }
}

class AdditionalInfoBlock extends StatelessWidget {
  const AdditionalInfoBlock({super.key, required this.contentDetails});

  final ContentDetails contentDetails;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Card.filled(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(contentDetails.supplier),
          ),
        ),
        ...contentDetails.additionalInfo.map(
          (e) => Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    );
  }
}
