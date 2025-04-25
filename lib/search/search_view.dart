import 'package:strumok/search/search_results.dart';
import 'package:strumok/search/search_top_bar/search_top_bar.dart';
import 'package:flutter/material.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SearchTopBar(), Expanded(child: SearchResults())],
    );
  }
}
