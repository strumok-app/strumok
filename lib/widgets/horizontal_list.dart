import 'package:flutter/material.dart';

class HorizontalList extends StatelessWidget {
  final Widget title;
  final NullableIndexedWidgetBuilder itemBuilder;
  final ScrollController? scrollController;
  final int itemCount;
  final double paddings;

  const HorizontalList({
    super.key,
    required this.title,
    required this.itemBuilder,
    required this.itemCount,
    this.paddings = 8,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddings),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: title),
          SizedBox(
            height: 260,
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: itemBuilder,
              itemCount: itemCount,
            ),
          )
        ],
      ),
    );
  }
}
