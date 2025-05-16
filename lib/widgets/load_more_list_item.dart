import 'package:flutter/material.dart';
import 'package:strumok/widgets/horizontal_list_card.dart';

class LoadMoreItems extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  final String label;

  const LoadMoreItems({
    super.key,
    required this.onTap,
    required this.label,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return HorizontalListCard(
      focusNode: FocusNode(canRequestFocus: !loading),
      onTap: () {
        FocusManager.instance.primaryFocus?.previousFocus();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loading
              ? CircularProgressIndicator()
              : const Icon(Icons.double_arrow, size: 48),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
