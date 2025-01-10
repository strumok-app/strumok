import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

abstract class ContentDetailsActions extends HookWidget {
  final ContentDetails contentDetails;

  const ContentDetailsActions(this.contentDetails, {super.key});

  @override
  Widget build(BuildContext context) {
    final mediaItemsFuture = useMemoized(() => Future.value(contentDetails.mediaItems));
    final snapshot = useFuture(mediaItemsFuture);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      return const SizedBox(height: 40);
    }

    final mediaItems = snapshot.data!.toList();

    if (mediaItems.isEmpty) {
      return const SizedBox(height: 40);
    }

    return renderActions(context, mediaItems);
  }

  Widget renderActions(BuildContext context, List<ContentMediaItem> mediaItems);
}
