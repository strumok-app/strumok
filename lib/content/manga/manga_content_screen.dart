import 'package:auto_route/auto_route.dart';
import 'package:strumok/content/details/content_details_provider.dart';
import 'package:strumok/content/manga/manga_reader.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class MangaContentScreen extends ConsumerStatefulWidget {
  const MangaContentScreen({
    super.key,
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  ConsumerState<MangaContentScreen> createState() => _MangaContentScreenState();
}

class _MangaContentScreenState extends ConsumerState<MangaContentScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(videoPlayerProvider.notifier).load(widget.supplier, widget.id);
      ref.read(floatingVideoPlayerProvider.notifier).hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(
      detailsAndMediaProvider(widget.supplier, widget.id),
    );
    return Stack(
      children: [
        const MangaBackground(),
        result.when(
          skipLoadingOnRefresh: false,
          data: (data) => MangaReader(
            contentDetails: data.contentDetails,
            mediaItems: data.mediaItems,
          ),
          error: (error, stackTrace) => DisplayError(
            error: error,
            onRefresh: () =>
                ref.refresh(detailsProvider(widget.supplier, widget.id).future),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
