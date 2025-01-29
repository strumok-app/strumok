import 'package:auto_route/annotations.dart';
import 'package:strumok/collection/active_collection_items_view.dart';
import 'package:strumok/home/recommendations/recommendations.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralLayout(
      selectedIndex: 0,
      child: ListView(
        children: const [ActiveCollectionItemsView(), Recommendations()],
      ),
    );
  }
}
