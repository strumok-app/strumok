import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

typedef SelectItemCallback = void Function(int idx);

class VideoContext extends InheritedWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  final VoidCallback next;
  final VoidCallback prev;
  final SelectItemCallback selectItem;

  const VideoContext({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
    required this.next,
    required this.prev,
    required this.selectItem,
    required super.child,
  });

  static VideoContext? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VideoContext>();
  }

  static VideoContext of(BuildContext context) {
    final VideoContext? result = maybeOf(context);
    assert(result != null, 'No VideoContext found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(VideoContext old) =>
      contentDetails != old.contentDetails || mediaItems != old.mediaItems;
}
