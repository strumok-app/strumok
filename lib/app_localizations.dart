import 'package:strumok/app_localizations.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/content/manga/model.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:strumok/content/video/model.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

String priorityLabel(
  BuildContext context,
  int priority,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (priority) {
    0 => localization.priorityLow,
    1 => localization.priorityNormal,
    _ => localization.priorityHight
  };
}

String mediaTypeLabel(
  BuildContext context,
  MediaType mediaType,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (mediaType) {
    MediaType.video => localization.mediaTypeVideo,
    MediaType.manga => localization.mediaTypeManga,
  };
}

String statusLabel(
  BuildContext context,
  MediaCollectionItemStatus status,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (status) {
    MediaCollectionItemStatus.inProgress => localization.statusLabelWatchingNow,
    MediaCollectionItemStatus.complete => localization.statusLabelComplete,
    MediaCollectionItemStatus.latter => localization.statusLabelLatter,
    MediaCollectionItemStatus.onHold => localization.statusLabelOnHold,
    _ => localization.addToCollection,
  };
}

String statusMenuItemLabel(
  BuildContext context,
  MediaCollectionItemStatus status,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (status) {
    MediaCollectionItemStatus.inProgress => localization.statusLabelWatchingNow,
    MediaCollectionItemStatus.complete => localization.statusLabelComplete,
    MediaCollectionItemStatus.latter => localization.statusLabelLatter,
    MediaCollectionItemStatus.onHold => localization.statusLabelPutOnHold,
    _ => localization.removeFromCollection,
  };
}

String contentTypeLabel(BuildContext context, ContentType type) {
  final localization = AppLocalizations.of(context)!;
  return switch (type) {
    ContentType.anime => localization.contentTypeAnime,
    ContentType.cartoon => localization.contentTypeCartoon,
    ContentType.movie => localization.contentTypeMovie,
    ContentType.series => localization.contentTypeSeries,
    ContentType.manga => localization.contentTypeManga,
  };
}

String mangaReaderScaleLabel(BuildContext context, MangaReaderScale mode) {
  final localization = AppLocalizations.of(context)!;
  return switch (mode) {
    MangaReaderScale.fit => localization.mangaReaderScaleFit,
    MangaReaderScale.fitHeight => localization.mangaReaderScaleFitHeight,
    MangaReaderScale.fitWidth => localization.mangaReaderScaleFitWidth,
  };
}

String mangaReaderBackgroundLabel(
    BuildContext context, MangaReaderBackground background) {
  final localization = AppLocalizations.of(context)!;
  return switch (background) {
    MangaReaderBackground.light => localization.mangaReaderBackgroundLight,
    MangaReaderBackground.dark => localization.mangaReaderBackgroundDark,
  };
}

String mangaReaderModeLabel(BuildContext context, MangaReaderMode mode) {
  final localization = AppLocalizations.of(context)!;
  return switch (mode) {
    MangaReaderMode.vertical => localization.mangaReaderModeVertical,
    MangaReaderMode.leftToRight => localization.mangaReaderModeLeftToRight,
    MangaReaderMode.rightToLeft => localization.mangaReaderModeRightToLeft,
    MangaReaderMode.vericalScroll => localization.mangaReaderModeVerticalScroll,
    MangaReaderMode.hotizontalScroll =>
      localization.mangaReaderModeHorizontalScroll,
    MangaReaderMode.hotizontalRtlScroll =>
      localization.mangaReaderModeHorizontalRtlScroll,
  };
}

String videoPlayerSettingEndsAction(
  BuildContext context,
  OnVideoEndsAction action,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (action) {
    OnVideoEndsAction.playNext =>
      localization.videoPlayerEndsActionPlayNextLabel,
    OnVideoEndsAction.playAgain =>
      localization.videoPlayerEndsActionPlayAgainLabel,
    OnVideoEndsAction.doNothing =>
      localization.videoPlayerEndsActionDoNothingLabel,
  };
}

String videoPlayerSettingStarFrom(
  BuildContext context,
  StarVideoPosition from,
) {
  final localization = AppLocalizations.of(context)!;
  return switch (from) {
    StarVideoPosition.fromBeginning =>
      localization.videoPlayerSettingStarFromBeginning,
    StarVideoPosition.fromRemembered =>
      localization.videoPlayerSettingStarFromRemembered,
    StarVideoPosition.fromFixedPosition =>
      localization.videoPlayerSettingStarFromFixed,
  };
}
