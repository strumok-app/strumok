import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:strumok/utils/nav.dart';

class ContentDetailsMangaActions extends StatelessWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const ContentDetailsMangaActions({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _renderReadButton(context),
        const SizedBox(width: 8),
        VolumesButton(contentDetails: contentDetails, mediaItems: mediaItems),
      ],
    );
  }

  Widget _renderReadButton(BuildContext context) {
    return SizedBox(
      width: 200,
      child: OutlinedButton.icon(
        autofocus: true,
        onPressed: () => navigateToContent(context, contentDetails),
        icon: const Icon(Icons.menu_book_outlined),
        label: Text(AppLocalizations.of(context)!.readButton),
      ),
    );
  }
}
