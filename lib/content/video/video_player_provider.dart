import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/utils/logger.dart';
import 'package:subtitle/subtitle.dart';

part 'video_player_provider.g.dart';

@riverpod
class CurrentSubtitleController extends _$CurrentSubtitleController {
  @override
  SubtitleController? build() {
    return null;
  }

  Future<void> setSubtitles(
    List<ContentMediaItemSource> currentSources,
    ContentProgress progress,
  ) async {
    final itemIdx = progress.currentItem;
    final currentSubtitle = progress.currentSubtitleName;

    if (currentSubtitle == null) {
      state = null;
      return;
    }

    final subtitles =
        currentSources.where((s) => s.kind == FileKind.subtitle).toList();
    final subtitle =
        subtitles.firstWhereOrNull((s) => s.description == currentSubtitle)
            as MediaFileItemSource?;

    if (subtitle == null) {
      state = null;
      return;
    }

    final controller = await Isolate.run(() async {
      final link = await subtitle.link;
      final controller = SubtitleController(
        provider: NetworkSubtitle(link, headers: subtitle.headers),
      );
      await controller.initial();

      return controller;
    }, debugName: "subtitles");

    if (progress.currentItem == itemIdx &&
        currentSubtitle == progress.currentSubtitleName) {
      logger.i("Subtitle: $subtitle");

      state = controller;
    }
  }
}

@riverpod
class PlayerErrors extends _$PlayerErrors {
  @override
  List<String> build() {
    return [];
  }

  void reset() {
    state = [];
  }

  void addError(String error) {
    state = [...state, error];
  }
}

@riverpod
class SubtitlesOffset extends _$SubtitlesOffset {
  @override
  Duration build() {
    return Duration(seconds: 0);
  }

  void setOffset(int inSeconds) {
    state = Duration(seconds: inSeconds);
  }
}

@riverpod
class ShuffleModeSettings extends _$ShuffleModeSettings {
  @override
  bool build() {
    return AppPreferences.videoPlayerSettingShuffleMode;
  }

  void select(bool enabled) {
    AppPreferences.videoPlayerSettingShuffleMode = enabled;
    state = enabled;
  }
}

@riverpod
class OnVideoEndsActionSettings extends _$OnVideoEndsActionSettings {
  @override
  OnVideoEndsAction build() {
    return AppPreferences.videoPlayerSettingEndsAction;
  }

  void select(OnVideoEndsAction action) {
    AppPreferences.videoPlayerSettingEndsAction = action;
    state = action;
  }
}

@riverpod
class StarVideoPositionSettings extends _$StarVideoPositionSettings {
  @override
  StarVideoPosition build() {
    return AppPreferences.videoPlayerSettingStarFrom;
  }

  void select(StarVideoPosition starFrom) {
    AppPreferences.videoPlayerSettingStarFrom = starFrom;
    state = starFrom;
  }
}

@riverpod
class FixedPositionSettings extends _$FixedPositionSettings {
  @override
  int build() {
    return AppPreferences.videoPlayerSettingFixedPosition;
  }

  void select(int position) {
    AppPreferences.videoPlayerSettingFixedPosition = position;
    state = position;
  }
}

@riverpod
Future<SourceSelectorModel> sourceSelector(
  Ref ref,
  ContentDetails contentDetails,
  List<ContentMediaItem> mediaItems,
) async {
  final (currentItem, currentSource, currentSubtitle) = await ref.watch(
    collectionItemProvider(contentDetails).selectAsync(
      (item) => (
        item.currentItem,
        item.currentSourceName,
        item.currentSubtitleName,
      ),
    ),
  );

  final sources = await mediaItems[currentItem].sources;

  return SourceSelectorModel(
    sources: sources,
    currentSource: currentSource,
    currentSubtitle: currentSubtitle,
  );
}
