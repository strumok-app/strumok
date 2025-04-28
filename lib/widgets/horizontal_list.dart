import 'package:flutter/material.dart';

class HorizontalList extends StatelessWidget {
  final Widget title;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? scrollController;
  final Widget? trailing;
  final int itemCount;
  final double paddings;

  const HorizontalList({
    super.key,
    required this.title,
    required this.itemBuilder,
    required this.itemCount,
    this.trailing,
    this.paddings = 8,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    var items = List.generate(itemCount, (idx) => itemBuilder(context, idx));

    if (trailing != null) {
      items.add(trailing!);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddings),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: title,
          ),
          SizedBox(
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: items),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
