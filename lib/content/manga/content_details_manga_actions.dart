import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/details/content_details_actions.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:strumok/utils/nav.dart';

class ContentDetailsMangaActions extends ContentDetailsActions {
  const ContentDetailsMangaActions(super.contentDetails, {super.key});

  @override
  Widget renderActions(
    BuildContext context,
    List<ContentMediaItem> mediaItems,
  ) {
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
