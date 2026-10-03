import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_api/segmented_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content/video/subtitle_worker.dart';
import 'package:strumok/utils/cache.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/trace.dart';
import 'package:strumok/video_backend/video_backend.dart';
import 'package:subtitle/subtitle.dart';

class VideoPlayerController {
  static final SimpleCache<SubCacheKey, SubtitleController> _subsCache =
      SimpleCache(10);

  final ContentDetails contentDetails;
  final SegmentedList<ContentMediaItem> mediaItems;

  final ChangeCollectionCurrentItemCallback changeCollectionCurrentItem;
  final _subtitleWorker = SubtitleWorker();

  List<int> _shuffledPositions = List.empty();
  Future<List<ContentMediaItemSource>>? _currentSources;

  int? _currentItem;

  String? _currentSourceName;
  String? _currentSubtitleName;

  ValueNotifier<AsyncValue<SubtitleController?>> subtitleController =
      ValueNotifier(AsyncValue.data(null));
  ValueNotifier<EdgeInsets> subtitlePaddings = ValueNotifier(EdgeInsets.zero);

  VideoBackend? _currentVideoBackend;
  ValueNotifier<AsyncValue<VideoBackend>> videoBackend = ValueNotifier(
    AsyncValue.loading(),
  );

  final StreamController<VideoBackendState> _videoBackendStateStreamController =
      StreamController.broadcast();
  VideoBackendState get videoBackendState =>
      _currentVideoBackend?.value ?? VideoBackendState.uninitialized();
  Stream<VideoBackendState> get videoBackendStateStream =>
      _videoBackendStateStreamController.stream;

  bool _disposed = false;

  VideoPlayerController({
    required this.contentDetails,
    required this.mediaItems,
    required this.changeCollectionCurrentItem,
  });

  void dispose() {
    _disposed = true;
    _subtitleWorker.dispose();
    _disposeCurrentVideoBackend();
    _videoBackendStateStreamController.close();

    videoBackend.dispose();
    subtitleController.dispose();
    subtitlePaddings.dispose();
  }

  void playOrPause() {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      if (backend!.value.isPlaying) {
        backend.pause();
      } else {
        backend.play();
      }
    }
  }

  void play() {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      backend!.play();
    }
  }

  void pause() {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      backend!.pause();
    }
  }

  void volumeChangeBy(double delta) {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      final currentVolume = backend!.value.volume;
      final newVolume = (currentVolume + delta).clamp(0.0, 1.0);

      AppPreferences.volume = newVolume;

      backend.setVolume(newVolume);
    }
  }

  void volumeUp() {
    if (_disposed) return;
    volumeChangeBy(0.05);
  }

  void volumeDown() {
    if (_disposed) return;
    volumeChangeBy(-0.05);
  }

  Future<void> setVolume(double volume) async {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      AppPreferences.volume = volume;

      await backend!.setVolume(volume);
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_disposed) return;

    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      backend!.seekTo(position);
    }
  }

  void seekForward(Duration duration) {
    if (_disposed) return;

    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      final currentPosition = backend!.value.position;
      final newPosition = currentPosition + duration;

      // Clamp to video duration if seeking beyond end
      final clampedPosition = newPosition > backend.value.duration
          ? backend.value.duration
          : newPosition;

      backend.seekTo(clampedPosition);
    }
  }

  void seekBackward(Duration duration) {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      final currentPosition = backend!.value.position;
      final newPosition = currentPosition - duration;

      // Clamp to zero if seeking before start
      final clampedPosition = newPosition < Duration.zero
          ? Duration.zero
          : newPosition;

      backend.seekTo(clampedPosition);
    }
  }

  Future<void> frameStepForward() async {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      await backend!.frameStepForward();
    }
  }

  Future<void> frameStepBackward() async {
    if (_disposed) return;
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      await backend!.frameStepBackward();
    }
  }

  void setRate(double rate) {
    if (_disposed) return;

    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      backend?.setPlaybackSpeed(rate);
    }
  }

  void setEquilizer(List<double> bands) {
    final backend = _currentVideoBackend;
    if (backend?.value.isInitialized == true) {
      backend!.setEquilizer(bands);
    }
  }

  Future<void> update(MediaCollectionItem collectionItem) async {
    if (_disposed) {
      return;
    }

    final itemChanged = _currentItem != collectionItem.currentItem;
    final sourceChanged =
        _currentSourceName != collectionItem.currentSourceName;
    final subtitleChanged =
        _currentSubtitleName != collectionItem.currentSubtitleName;

    // Both start synchronously in call order, so the latest update always owns the state.
    await Future.wait([
      if (itemChanged || sourceChanged) _playCollectionItem(collectionItem),
      if (itemChanged || subtitleChanged) _loadSubtitles(collectionItem),
    ]);
  }

  void _disposeCurrentVideoBackend() {
    _currentVideoBackend?.dispose();
    _currentVideoBackend = null;
  }

  Future<void> _playCollectionItem(MediaCollectionItem collectionItem) async {
    try {
      // reset state
      _currentSources = null;
      _disposeCurrentVideoBackend();
      videoBackend.value = AsyncValue.loading();
      _videoBackendStateStreamController.add(VideoBackendState.uninitialized());

      // select source
      _currentItem = collectionItem.currentItem;
      _currentSourceName = collectionItem.currentSourceName;

      final item = mediaItems[_currentItem!];
      if (item == null) {
        videoBackend.value = AsyncValue.error(
          "Video not available",
          StackTrace.current,
        );
        return;
      }

      final sourcesFuture = Future.value(item.sources);
      _currentSources = sourcesFuture;
      final sources = await sourcesFuture;

      if (_disposed ||
          _currentItem != collectionItem.currentItem ||
          _currentSourceName != collectionItem.currentSourceName) {
        return;
      }

      final videos = sources.where((s) => s.kind == FileKind.video).toList();

      var video = _currentSourceName == null
          ? videos.firstOrNull as VideoMediaItemSource?
          : videos.firstWhereOrNull((s) => s.description == _currentSourceName)
                as VideoMediaItemSource?;

      if (video == null && _currentSourceName != null) {
        video = videos.firstOrNull as VideoMediaItemSource?;
      }

      if (video == null) {
        videoBackend.value = AsyncValue.error(
          "Video source $_currentSourceName not avalaible",
          StackTrace.current,
        );
        return;
      }

      final link = await video.link;

      if (_disposed ||
          _currentItem != collectionItem.currentItem ||
          _currentSourceName != collectionItem.currentSourceName) {
        return;
      }

      // select start position
      final startPosition = AppPreferences.videoPlayerSettingStarFrom;

      int start = switch (startPosition) {
        StartVideoPosition.fromBeginning => 0,
        StartVideoPosition.fromRemembered => collectionItem.currentPosition,
        StartVideoPosition.fromFixedPosition =>
          AppPreferences.videoPlayerSettingFixedPosition,
      };

      final currentItemPosition = collectionItem.currentMediaItemPosition;
      if (currentItemPosition.length > 0 &&
          start > currentItemPosition.length - 60) {
        start = start - 60;
      }
      start = max(0, start);

      logger.info(
        "Starting video: $link, headers: ${video.headers}, startPos: $start",
      );

      final newVideoBackend = VideoBackend.create();

      _currentVideoBackend = newVideoBackend;
      await newVideoBackend.initialize(
        link,
        headers: video.headers ?? {},
        start: Duration(seconds: start),
        preferredLanguage: {
          if (AppPreferences.userLanguage != null) AppPreferences.userLanguage!,
          "en",
        },
        hlsProxy: video.hlsProxy,
      );

      if (_disposed ||
          _currentVideoBackend != newVideoBackend ||
          _currentItem != collectionItem.currentItem ||
          _currentSourceName != collectionItem.currentSourceName) {
        // Otherwise it was already disposed by dispose() or a newer request.
        if (_currentVideoBackend == newVideoBackend) {
          _disposeCurrentVideoBackend();
        }
        return;
      }

      videoBackend.value = AsyncValue.data(newVideoBackend);
      _videoBackendStateStreamController.add(newVideoBackend.value);

      var wasEnded = false;
      newVideoBackend.addListener(() {
        if (_disposed || _currentVideoBackend != newVideoBackend) {
          return;
        }

        final value = newVideoBackend.value;
        _videoBackendStateStreamController.add(value);

        if (value.hasError) {
          if (videoBackend.value is! AsyncError) {
            videoBackend.value = AsyncValue.error(
              value.error ?? "Playback error",
              StackTrace.current,
            );
          }
          return;
        }

        if (value.isEnded && !wasEnded) {
          _onVideoEnds();
        }
        wasEnded = value.isEnded;
      });

      // set equalizer
      newVideoBackend.setEquilizer(AppPreferences.videoPlayerEqualizerBands);

      // set volume
      newVideoBackend.setVolume(AppPreferences.volume);
    } catch (e, stackTrace) {
      if (e is ContentSuppliersException) {
        traceError(
          error: e,
          stackTrace: stackTrace,
          message: "fail to start video",
        );
      } else {
        logger.severe("Fail to start video", e, stackTrace);
      }

      if (_disposed ||
          _currentItem != collectionItem.currentItem ||
          _currentSourceName != collectionItem.currentSourceName) {
        return;
      }

      _disposeCurrentVideoBackend();
      videoBackend.value = AsyncValue.error(e, stackTrace);
      _videoBackendStateStreamController.add(
        VideoBackendState.erroneous(e.toString()),
      );
    }
  }

  void _onVideoEnds() async {
    switch (AppPreferences.videoPlayerSettingEndsAction) {
      case OnVideoEndsAction.playNext:
        nextItem();
      case OnVideoEndsAction.playAgain:
        if (_currentVideoBackend != null) {
          final videoController = _currentVideoBackend!;
          await videoController.seekTo(Duration.zero);
          await videoController.play();
        }
      case OnVideoEndsAction.doNothing: // do nothing
    }
  }

  void nextItem() {
    if (_disposed || mediaItems.isEmpty) return;

    if (AppPreferences.videoPlayerSettingShuffleMode) {
      final shuffledPosition = _getShuffledPosition();
      changeCollectionCurrentItem(shuffledPosition);
      return;
    }

    final currentIndex = _currentItem ?? 0;
    if (currentIndex >= mediaItems.length - 1) return;

    final nextIndex = currentIndex + 1;
    changeCollectionCurrentItem(nextIndex);
  }

  int _getShuffledPosition() {
    if (_shuffledPositions.isEmpty) {
      final shuffledPositions = List.generate(mediaItems.length, (i) => i);
      final rng = Random();

      // Fisher-Yates shuffle
      for (int i = shuffledPositions.length - 1; i > 0; i--) {
        final j = rng.nextInt(i + 1);
        // Swap elements at positions i and j
        final temp = shuffledPositions[i];
        shuffledPositions[i] = shuffledPositions[j];
        shuffledPositions[j] = temp;
      }

      _shuffledPositions = shuffledPositions;
    }

    return _shuffledPositions.removeAt(0);
  }

  void prevItem() {
    if (_disposed || mediaItems.isEmpty) return;

    final currentIndex = _currentItem ?? 0;
    if (currentIndex <= 0) return;

    final prevIndex = currentIndex - 1;
    changeCollectionCurrentItem(prevIndex);
  }

  Future<void> _loadSubtitles(MediaCollectionItem collectionItem) async {
    if (_disposed || _currentItem != collectionItem.currentItem) {
      return;
    }

    final itemIdx = collectionItem.currentItem;
    final subtitleName = collectionItem.currentSubtitleName;
    final sourcesFuture = _currentSources;
    _currentSubtitleName = subtitleName;

    bool isStale() =>
        _disposed ||
        _currentItem != itemIdx ||
        _currentSubtitleName != subtitleName;

    if (subtitleName == null || sourcesFuture == null) {
      subtitleController.value = AsyncValue.data(null);
      return;
    }

    final cacheKey = SubCacheKey(
      contentDetails.supplier,
      contentDetails.id,
      itemIdx,
      subtitleName,
    );

    final cachedSub = _subsCache.get(cacheKey);
    if (cachedSub != null) {
      subtitleController.value = AsyncValue.data(cachedSub);
      return;
    }

    subtitleController.value = AsyncValue.loading();

    try {
      final sources = await sourcesFuture;
      if (isStale()) {
        return;
      }

      final subtitle =
          sources
                  .where((s) => s.kind == FileKind.subtitle)
                  .firstWhereOrNull((s) => s.description == subtitleName)
              as FileMediaItemSource?;

      if (subtitle == null) {
        subtitleController.value = AsyncValue.data(null);
        return;
      }

      logger.info("Loading subtitle: $subtitle");

      // Use the subtitle worker to parse subtitle in isolate
      final link = await subtitle.link;
      final controller = await _subtitleWorker.parseSubtitle(
        link.toString(),
        subtitle.headers,
      );

      if (isStale()) {
        return;
      }

      _subsCache.put(cacheKey, controller);
      subtitleController.value = AsyncValue.data(controller);

      logger.info("Subtitle loaded successfully");
    } catch (e, stackTrace) {
      logger.severe("Fail to load subtitle", e, stackTrace);

      // do not show error for not currently selected subs
      if (isStale()) {
        return;
      }

      subtitleController.value = AsyncValue.error(e, stackTrace);
    }
  }
}

class VideoContentControllerInheritedWidget extends InheritedWidget {
  final VideoPlayerController controller;

  const VideoContentControllerInheritedWidget({
    super.key,
    required this.controller,
    required super.child,
  });

  static VideoContentControllerInheritedWidget? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<
          VideoContentControllerInheritedWidget
        >();
  }

  static VideoContentControllerInheritedWidget of(BuildContext context) {
    final VideoContentControllerInheritedWidget? result = maybeOf(context);
    assert(
      result != null,
      'No VideoContentControllerInheritedWidget found in context',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(VideoContentControllerInheritedWidget oldWidget) =>
      controller != oldWidget.controller;
}

VideoPlayerController videoContentController(BuildContext context) =>
    VideoContentControllerInheritedWidget.of(context).controller;
