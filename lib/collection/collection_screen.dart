import 'package:auto_route/annotations.dart';
import 'package:strumok/collection/collection_top_bar.dart';
import 'package:strumok/collection/horizontal_list/horizontal_list_view.dart';
import 'package:strumok/layouts/general_layout.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GeneralLayout(
      selectedIndex: 2,
      child: Column(
        children: [
          CollectionTopBar(),
          Expanded(child: CollectionHorizontalView()),
        ],
      ),
    );
  }
}
