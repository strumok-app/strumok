import 'package:auto_route/auto_route.dart';
import 'package:strumok/content/details/content_details_provider.dart';
import 'package:strumok/content/video/video_content_view.dart';
import 'package:strumok/widgets/display_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class VideoContentScreen extends ConsumerStatefulWidget {
  const VideoContentScreen({
    super.key,
    required this.supplier,
    required this.id,
  });

  final String supplier;
  final String id;

  @override
  ConsumerState<VideoContentScreen> createState() => _VideoContentScreenState();
}

class _VideoContentScreenState extends ConsumerState<VideoContentScreen> {
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(
      detailsAndMediaProvider(widget.supplier, widget.id),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: result.when(
        skipLoadingOnRefresh: false,
        data: (data) => VideoContentView(
          contentDetails: data.contentDetails,
          mediaItems: data.mediaItems,
        ),
        error: (error, stackTrace) => DisplayError(
          error: error,
          onRefresh: () =>
              ref.refresh(detailsProvider(widget.supplier, widget.id).future),
        ),
        loading: () => const Material(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      ),
    );
  }
}
