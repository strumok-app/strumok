import 'dart:async';

import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_api/segmented_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/details/content_details_provider.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content/video/video_player_controller.dart';
import 'package:strumok/video_backend/video_backend.dart';

part 'video_player_provider.g.dart';

@Riverpod(keepAlive: true)
class FloatingVideoPlayer extends _$FloatingVideoPlayer {
  @override
  bool build() {
    return true;
  }

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}

@Riverpod(keepAlive: true)
class VideoPlayer extends _$VideoPlayer {
  List<ProviderSubscription> _providerSubscriptions = [];
  StreamSubscription<VideoBackendState>? _playerStreamSubscription;

  @override
  FutureOr<VideoPlayerController?> build() async {
    return null;
  }

  void load(String supplier, String id) async {
    final currentController = state.value;
    if (currentController != null) {
      if (currentController.contentDetails.supplier == supplier &&
          currentController.contentDetails.id == id) {
        return;
      }

      _clearSubscriptions();
      currentController.dispose();
    }

    state = AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final data = await ref.read(detailsAndMediaProvider(supplier, id).future);

      final controller = VideoPlayerController(
        contentDetails: data.contentDetails,
        mediaItems: data.mediaItems,
        changeCollectionCurrentItem: (itemIdx) {
          ref
              .read(collectionItemProvider(data.contentDetails).notifier)
              .setCurrentItem(itemIdx);
        },
      );

      final collectionItemSub = ref.listen(
        collectionItemProvider(data.contentDetails),
        (previous, next) {
          next.whenData((collectionItem) {
            controller.update(collectionItem);
          });
        },
        fireImmediately: true,
      );

      _providerSubscriptions.add(collectionItemSub);

      final eqailizerSub = ref.listen(equalizerBandsSettingsProvider, (
        previous,
        next,
      ) {
        controller.setEquilizer(next);
      });

      _providerSubscriptions.add(eqailizerSub);

      _playerStreamSubscription = controller.videoBackendStateStream.listen((
        playerValue,
      ) {
        // Update collection item position when player position changes
        if (playerValue.position > Duration.zero) {
          ref
              .read(collectionItemProvider(data.contentDetails).notifier)
              .setCurrentPosition(
                playerValue.position.inSeconds,
                playerValue.duration.inSeconds,
              );
        }
      });

      return controller;
    });
  }

  void _clearSubscriptions() {
    _providerSubscriptions.forEach((sub) => sub.close());
    _providerSubscriptions.clear();
    _playerStreamSubscription?.cancel();
    _playerStreamSubscription = null;
  }

  void dispose() {
    _clearSubscriptions();

    state.value?.dispose();
    state = AsyncValue.data(null);
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
class StartVideoPositionSettings extends _$StartVideoPositionSettings {
  @override
  StartVideoPosition build() {
    return AppPreferences.videoPlayerSettingStarFrom;
  }

  void select(StartVideoPosition starFrom) {
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
class EqualizerBandsSettings extends _$EqualizerBandsSettings {
  @override
  List<double> build() {
    return AppPreferences.videoPlayerEqualizerBands;
  }

  void updateBand(int index, double value) {
    final newBands = List<double>.from(state);
    newBands[index] = value;
    AppPreferences.videoPlayerEqualizerBands = newBands;
    state = newBands;
  }

  void reset() {
    AppPreferences.videoPlayerEqualizerBands =
        AppConstances.equalizerDefaultBands;
    state = AppConstances.equalizerDefaultBands;
  }

  void setPreset(List<double> preset) {
    AppPreferences.videoPlayerEqualizerBands = preset;
    state = preset;
  }
}

@riverpod
Future<SourceSelectorModel> sourceSelector(
  Ref ref,
  ContentDetails contentDetails,
  SegmentedList<ContentMediaItem> mediaItems,
) async {
  final (currentItem, currentSource, currentSubtitle) = await ref.watch(
    collectionItemProvider(contentDetails).selectAsync(
      (item) =>
          (item.currentItem, item.currentSourceName, item.currentSubtitleName),
    ),
  );

  final sources = await mediaItems[currentItem]?.sources ?? [];

  return SourceSelectorModel(
    sources: sources,
    currentSource: currentSource,
    currentSubtitle: currentSubtitle,
  );
}
