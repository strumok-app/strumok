import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:readmore/readmore.dart';
import 'package:strumok/app_localizations.dart';
import 'package:strumok/content/details/widgets.dart';
import 'package:strumok/content/manga/content_details_manga_actions.dart';
import 'package:strumok/content/video/content_details_video_actions.dart';
import 'package:strumok/widgets/nothing_to_show.dart';

class ContentDetailsMobileView extends StatelessWidget {
  final ContentDetails contentDetails;

  const ContentDetailsMobileView({required this.contentDetails, super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      child: Column(
        children: [
          Theme(
            data: ThemeData(
              colorSchemeSeed: color,
              brightness: Brightness.dark,
            ),
            child: _MainAccentBlock(contentDetails: contentDetails),
          ),
          _InfoBlock(contentDetails: contentDetails),
        ],
      ),
    );
  }
}

class _MainAccentBlock extends HookWidget {
  final ContentDetails contentDetails;

  const _MainAccentBlock({required this.contentDetails});

  @override
  Widget build(BuildContext context) {
    final showPoster = useState(false);
    final screenWidth = MediaQuery.of(context).size.width;
    final background = Theme.of(context).colorScheme.surface;

    return Stack(
      children: [
        // height placeholder
        Material(
          elevation: 5,
          color: background,
          child: GestureDetector(
            onTap: () {
              showPoster.value = !showPoster.value;
            },
            child: CachedNetworkImage(
              imageUrl: contentDetails.image,
              fit: BoxFit.fitWidth,
              width: screenWidth,
              placeholder:
                  (context, url) => _buildImagePlaceholder(screenWidth),
              errorWidget:
                  (context, url, error) => Center(child: NothingToShow()),
            ),
          ),
        ),
        if (!showPoster.value) ...[
          Positioned.fill(
            child: Align(
              alignment: Alignment.topLeft,
              child: _TitleBox(contentDetails: contentDetails),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: _renderContentActions(screenWidth),
            ),
          ),
        ],
      ],
    );
  }

  SizedBox _buildImagePlaceholder(double screenWidth) {
    return SizedBox(
      height: 400,
      width: screenWidth,
      child: const Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _renderContentActions(double screenWidth) {
    return Container(
      height: 128,
      width: screenWidth,
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black54, Colors.black],
          stops: [0, 0.4, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: switch (contentDetails.mediaType) {
          MediaType.video => ContentDetailsVideoActions(contentDetails),
          MediaType.manga => ContentDetailsMangaActions(contentDetails),
        },
      ),
    );
  }
}

class _TitleBox extends StatelessWidget {
  const _TitleBox({required this.contentDetails});

  final ContentDetails contentDetails;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(contentDetails.title, style: textTheme.bodyLarge),
        if (contentDetails.secondaryTitle != null)
          Text(contentDetails.secondaryTitle!, style: textTheme.bodyLarge),
        const SizedBox(height: 8),
      ],
    );

    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54, Colors.black87],
                stops: [0, 0.3, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: title,
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final ContentDetails contentDetails;
  const _InfoBlock({required this.contentDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediaCollectionItemButtons(contentDetails: contentDetails),
          const SizedBox(height: 8),
          AdditionalInfoBlock(contentDetails: contentDetails),
          const SizedBox(height: 8),
          _renderDescription(context),
          if (contentDetails.similar.isNotEmpty) ...[
            const SizedBox(height: 8),
            SimilarBlock(contentDetails: contentDetails),
          ],
        ],
      ),
    );
  }

  Widget _renderDescription(BuildContext context) {
    final theme = Theme.of(context);

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
