import 'package:auto_route/auto_route.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:strumok/content/details/content_details_provider.dart';
import 'package:strumok/content/details/content_details_view.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class ContentDetailsScreen extends ConsumerWidget {
  const ContentDetailsScreen({
    super.key,
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(detailsProvider(supplier, id));

    return GeneralLayout(
      showBackButton: true,
      child: details.when(
        data: (data) => ContentDetailsView(data),
        error: (error, stackTrace) => DisplayError(
          error: error,
          onRefresh: () => ref.invalidate(detailsProvider(supplier, id)),
          actions: [_RemoveFromCollectionButton(supplier: supplier, id: id)],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _RemoveFromCollectionButton extends ConsumerWidget {
  const _RemoveFromCollectionButton({
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCollection = ref.watch(hasCollectionItemProvider(supplier, id)).valueOrNull ?? false;

    return inCollection
        ? OutlinedButton(
            onPressed: () {
              ref.read(collectionServiceProvider).delete(supplier, id);
            },
            child: Text(AppLocalizations.of(context)!.removeFromCollection),
          )
        : const SizedBox.shrink();
  }
}
