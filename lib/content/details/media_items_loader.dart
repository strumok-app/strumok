import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

typedef Builder =
    Widget Function(BuildContext context, List<ContentMediaItem> mediaItems);

class MediaItemsLoader extends StatelessWidget {
  final ContentDetails contentDetails;
  final Builder builder;

  const MediaItemsLoader({
    super.key,
    required this.contentDetails,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Iterable<ContentMediaItem>>(
      future: Future.value(contentDetails.mediaItems),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox(height: 40);
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            width: 40,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final mediaItems = snapshot.data!;
        if (mediaItems.isEmpty) {
          return const SizedBox(height: 40);
        }

        return builder(context, mediaItems.toList());
      },
    );
  }
}
