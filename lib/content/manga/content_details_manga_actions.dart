import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/content_details_actions.dart';
import 'package:strumok/content/manga/widgets.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strumok/utils/visual.dart';

class ContentDetailsMangaActions extends ContentDetailsActions {
  const ContentDetailsMangaActions(super.contentDetails, {super.key});

  @override
  Widget renderActions(
      BuildContext context, List<ContentMediaItem> mediaItems) {
    return Row(
      children: [
        _renderReadButton(context),
        const SizedBox(width: 8),
        VolumesButton(
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        )
      ],
    );
  }

  Widget _renderReadButton(BuildContext context) {
    return SizedBox(
      width: 200,
      child: FilledButton.tonalIcon(
        autofocus: true,
        onPressed: () {
          context.push(
              "/${contentDetails.mediaType.name}/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}");
        },
        icon: const Icon(Icons.menu_book_outlined),
        label: Text(AppLocalizations.of(context)!.readButton),
      ),
    );
  }
}
