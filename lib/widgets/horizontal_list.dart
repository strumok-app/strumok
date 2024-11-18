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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: paddings),
          child: title,
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            controller: scrollController,
            padding:
                EdgeInsets.only(bottom: 8, left: paddings, right: paddings),
            scrollDirection: Axis.horizontal,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        )
      ],
    );
  }
}
