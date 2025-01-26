import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:strumok/app_localizations.dart';
import 'package:strumok/layouts/general_layout.dart';

@RoutePage()
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(AppLocalizations.of(context)!.downloadsQueue),
            ),
          ],
        ),
      ),
    );
  }
}
