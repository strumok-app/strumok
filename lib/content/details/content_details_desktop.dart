import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:readmore/readmore.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/details/widgets.dart';
import 'package:strumok/content/manga/content_details_manga_actions.dart';
import 'package:strumok/content/video/content_details_video_actions.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/widgets/focus_indicator.dart';
import 'package:strumok/widgets/nothing_to_show.dart';

class ContentDetailsDesktopView extends StatelessWidget {
  final ContentDetails contentDetails;
  const ContentDetailsDesktopView({super.key, required this.contentDetails});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final screanHeight = size.height;
    final screanWidth = size.width;
    final compact = _isCompactLayout(context);

    return SizedBox.expand(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: _InfoBlock(contentDetails: contentDetails, compact: compact),
          ),
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                constraints: BoxConstraints(maxWidth: screanWidth * .4),
                child: CachedNetworkImage(
                  imageUrl: contentDetails.image,
                  height: screanHeight,
                  fit: BoxFit.contain,
                  errorWidget:
                      (context, url, error) => Center(child: NothingToShow()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final bool compact;
  final ContentDetails contentDetails;
  const _InfoBlock({required this.contentDetails, required this.compact});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _renderTitleBox(context),
                      const SizedBox(height: 8),
                      _ContentActionsButtons(contentDetails: contentDetails),
                      MediaCollectionItemButtons(
                        contentDetails: contentDetails,
                      ),
                      const SizedBox(height: 8),
                      AdditionalInfoBlock(contentDetails: contentDetails),
                    ],
                  ),
                ),
                if (compact) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: contentDetails.image,
                      width: 250,
                      errorWidget:
                          (context, url, error) =>
                              Center(child: NothingToShow()),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _renderDescription(context),
            if (contentDetails.similar.isNotEmpty) ...[
              const SizedBox(height: 8),
              SimilarBlock(contentDetails: contentDetails),
            ],
          ],
        ),
      ),
    );
  }

  Widget _renderTitleBox(BuildContext context) {
    final theme = Theme.of(context);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          contentDetails.title,
          style: theme.textTheme.headlineLarge?.copyWith(height: 1),
        ),
        if (contentDetails.secondaryTitle != null)
          SelectableText(
            contentDetails.secondaryTitle!,
            style: theme.textTheme.bodyMedium,
          ),
      ],
    );

    return FocusIndicator(child: title);
  }

  Widget _renderDescription(BuildContext context) {
    final theme = Theme.of(context);

    if (TVDetector.isTV || compact) {
      return Text(contentDetails.description, style: theme.textTheme.bodyLarge);
    }

    return ReadMoreText(
      contentDetails.description,
      trimMode: TrimMode.Line,
      trimLines: 4,
      trimCollapsedText: AppLocalizations.of(context)!.readMore,
      trimExpandedText: AppLocalizations.of(context)!.readLess,
      style: theme.textTheme.bodyLarge?.copyWith(inherit: true),
    );
  }
}

class _ContentActionsButtons extends HookWidget {
  final ContentDetails contentDetails;
  const _ContentActionsButtons({required this.contentDetails});

  @override
  Widget build(BuildContext context) {
    return switch (contentDetails.mediaType) {
      MediaType.video => ContentDetailsVideoActions(contentDetails),
      MediaType.manga => ContentDetailsMangaActions(contentDetails),
    };
  }
}

bool _isCompactLayout(BuildContext context) {
  return MediaQuery.of(context).size.width < 850;
}
