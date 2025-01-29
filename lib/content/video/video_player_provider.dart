import 'package:content_suppliers_api/model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/model.dart';

part 'video_player_provider.g.dart';

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
