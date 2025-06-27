import 'package:flutter/material.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';

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
    final size = HorizontalListCard.calcSize(context);
    final fullItemsCount = trailing != null ? itemCount + 1 : itemCount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddings),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
            child: title,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              height: size.height,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                itemCount: fullItemsCount,
                itemBuilder:
                    (context, index) =>
                        trailing != null && index == fullItemsCount - 1
                            ? trailing
                            : itemBuilder(context, index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
