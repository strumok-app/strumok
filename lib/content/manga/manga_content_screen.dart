import 'package:auto_route/auto_route.dart';
import 'package:strumok/content/details/content_details_provider.dart';
import 'package:strumok/content/manga/manga_reader.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class MangaContentScreen extends ConsumerWidget {
  const MangaContentScreen({
    super.key,
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(detailsAndMediaProvider(supplier, id));
    return SafeArea(
      child: Scaffold(
        body: result.when(
          data: (data) => MangaReader(
            contentDetails: data.contentDetails,
            mediaItems: data.mediaItems,
          ),
          error: (error, stackTrace) => DisplayError(
            error: error,
            onRefresh: () => ref.refresh(detailsProvider(supplier, id).future),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
