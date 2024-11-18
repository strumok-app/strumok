import 'package:strumok/app_localizations.dart';
import 'package:flutter/material.dart';

class SetRecommendationsHint extends StatelessWidget {
  const SetRecommendationsHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.recommend_outlined,
          size: 96,
        ),
        Text(
          AppLocalizations.of(context)!.setRecommendationsHint,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
