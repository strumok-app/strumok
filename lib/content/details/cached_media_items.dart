import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

typedef Builder =
    Widget Function(BuildContext context, List<ContentMediaItem> mediaItems);

class CachedMediaItems extends StatefulWidget {
  final ContentDetails contentDetails;
  final Builder builder;

  const CachedMediaItems({
    super.key,
    required this.contentDetails,
    required this.builder,
  });

  @override
  State<CachedMediaItems> createState() => _CachedMediaItemsState();
}

class _CachedMediaItemsState extends State<CachedMediaItems> {
  List<ContentMediaItem>? mediaItems;
  String? error;

  @override
  void initState() {
    Future.value(widget.contentDetails.mediaItems)
        .then((items) {
          setState(() {
            mediaItems = items.toList();
          });
        })
        .catchError((e) {
          setState(() {
            error = e;
          });
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (mediaItems == null) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return const SizedBox(height: 40);
    }

    if (mediaItems!.isEmpty) {
      return const SizedBox(height: 40);
    }

    return widget.builder(context, mediaItems!);
  }
}
