import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/utils/nav.dart';

class PickRandomButton extends ConsumerWidget {
  final List<ContentInfo> contentList;

  const PickRandomButton({Key? key, required this.contentList})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: contentList.isNotEmpty
          ? () {
              final randomIndex =
                  (contentList.length *
                          (new DateTime.now().millisecondsSinceEpoch % 1000) /
                          1000)
                      .floor();

              final randomContent = contentList[randomIndex];
              navigateToContentDetails(context, randomContent);
            }
          : null,
      icon: const Icon(Icons.shuffle),
    );
  }
}
