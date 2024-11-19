import 'package:strumok/collection/active_collection_items_view.dart';
import 'package:strumok/home/recommendations/recommendations.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:strumok/utils/visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paddings = getPadding(context);

    return GeneralLayout(
      selectedIndex: 0,
      child: ListView(
        padding: EdgeInsets.only(top: paddings),
        children: const [ActiveCollectionItemsView(), Recommendations()],
      ),
    );
  }
}