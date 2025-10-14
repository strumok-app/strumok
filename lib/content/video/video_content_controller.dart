import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
// import 'package:fvp/fvp.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content/video/subtitle_worker.dart';
import 'package:strumok/utils/cache.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/trace.dart';
import 'package:subtitle/subtitle.dart';
import 'package:video_player/video_player.dart';

extension VideoPlayerValueExt on VideoPlayerValue {
  Duration get lastBuffer => buffered.lastOrNull?.end ?? Duration.zero;
  bool get isEnded =>
      duration > Duration.zero && position >= duration && !isPlaying;
}

typedef ChangeCollectionCurrentItemCallback = void Function(int);

class VideoContentController {
  static final SimpleCache<SubCacheKey, SubtitleController> _subsCache =
      SimpleCache(10);

  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  final ChangeCollectionCurrentItemCallback changeCollectionCurentItem;
  final _subtitleWorker = SubtitleWorker();

  List<int> _shuffledPositions = List.empty();
  List<ContentMediaItemSource>? _currentSources;

  int? _currentItem;

  String? _currentSourceName;
  String? _currentSubtitleName;

  ValueNotifier<AsyncValue<VideoPlayerController>> playerController =
      ValueNotifier(AsyncValue.loading());
  VideoPlayerController? get _videoPlayerController =>
      playerController.value.valueOrNull;

  VideoPlayerValue get playerState =>
      _videoPlayerController?.value ?? VideoPlayerValue.uninitialized();

  final StreamController<VideoPlayerValue> _playerStateStreamController =
      StreamController.broadcast();
  Stream<VideoPlayerValue> get playerStream =>
      _playerStateStreamController.stream;

  ValueNotifier<AsyncValue<SubtitleController?>> subtitleController =
      ValueNotifier(AsyncValue.data(null));
  ValueNotifier<EdgeInsets> subtitlePaddings = ValueNotifier(EdgeInsets.zero);

  bool _disposed = false;

  VideoContentController({
    required this.contentDetails,
    required this.mediaItems,
    required this.changeCollectionCurentItem,
  });

  void playOrPause() {
    if (_disposed) return;
    final controller = _videoPlayerController;
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    }
  }

  void play() {
    if (_disposed) return;
    _videoPlayerController?.play();
  }

  void pause() {
    if (_disposed) return;
    _videoPlayerController?.pause();
  }

  void volumeChangeBy(double delta) {
    if (_disposed) return;
    final controller = _videoPlayerController;
    if (controller != null) {
      final currentVolume = controller.value.volume;
      final newVolume = (currentVolume + delta).clamp(0.0, 1.0);
      controller.setVolume(newVolume);
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
    final controller = _videoPlayerController;
    if (controller != null) {
      await controller.setVolume(volume);
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_disposed) return;
    _videoPlayerController?.seekTo(position);
  }

  void seekForward(Duration duration) {
    if (_disposed) return;
    final controller = _videoPlayerController;
    if (controller == null) return;

    final currentPosition = controller.value.position;
    final newPosition = currentPosition + duration;

    // Clamp to video duration if seeking beyond end
    final clampedPosition = newPosition > controller.value.duration
        ? controller.value.duration
        : newPosition;

    seekTo(clampedPosition);
  }

  void seekBackward(Duration duration) {
    if (_disposed) return;
    final controller = _videoPlayerController;
    if (controller == null) return;

    final currentPosition = controller.value.position;
    final newPosition = currentPosition - duration;

    // Clamp to zero if seeking before start
    final clampedPosition = newPosition < Duration.zero
        ? Duration.zero
        : newPosition;

    seekTo(clampedPosition);
  }

  void setRate(double rate) {
    if (_disposed) return;
    _videoPlayerController?.setPlaybackSpeed(rate);
  }

  void dispose() {
    _disposed = true;
    _subtitleWorker.dispose();
    _videoPlayerController?.dispose();
    _playerStateStreamController.close();
    playerController.dispose();
    subtitleController.dispose();
    subtitlePaddings.dispose();
  }

  Future<void> update(MediaCollectionItem collectionItem) async {
    if (_disposed) {
      return;
    }

    if (_currentItem != collectionItem.currentItem) {
      await _playCollectionItem(collectionItem);
      await _loadSubtitles(collectionItem);
    }

    if (_currentSourceName != collectionItem.currentSourceName) {
      await _playCollectionItem(collectionItem);
    }

    if (_currentSubtitleName != collectionItem.currentSubtitleName) {
      await _loadSubtitles(collectionItem);
    }
  }

  Future<void> _playCollectionItem(MediaCollectionItem collectionItem) async {
    try {
      // reset state
      _currentSources = null;
      _videoPlayerController?.dispose();
      playerController.value = AsyncValue.loading();
      _playerStateStreamController.add(VideoPlayerValue.uninitialized());

      // select source
      _currentItem = collectionItem.currentItem;
      _currentSourceName = collectionItem.currentSourceName;

      final item = mediaItems[_currentItem!];
      final sources = await item.sources;

      if (_disposed ||
          _currentItem != collectionItem.currentItem ||
          _currentSourceName != collectionItem.currentSourceName) {
        return;
      }

      _currentSources = sources;

      final videos = sources.where((s) => s.kind == FileKind.video).toList();

      var video = _currentSourceName == null
          ? videos.firstOrNull as MediaFileItemSource?
          : videos.firstWhereOrNull((s) => s.description == _currentSourceName)
                as MediaFileItemSource?;

      if (video == null && _currentSourceName != null) {
        video = videos.firstOrNull as MediaFileItemSource?;
      }

      if (video == null) {
        playerController.value = AsyncValue.error(
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

      final startPosition = AppPreferences.videoPlayerSettingStarFrom;

      int start = switch (startPosition) {
        StarVideoPosition.fromBeginning => 0,
        StarVideoPosition.fromRemembered => collectionItem.currentPosition,
        StarVideoPosition.fromFixedPosition =>
          AppPreferences.videoPlayerSettingFixedPosition,
      };

      final currentItemPosition = collectionItem.currentMediaItemPosition;
      if (currentItemPosition.length > 0 &&
          start > currentItemPosition.length - 60) {
        start = start - 60;
      } else if (start < 0) {
        start = 0;
      }

      logger.info("Starting video: $link, headers: ${video.headers}");

      final videoController = VideoPlayerController.networkUrl(
        link,
        httpHeaders: video.headers ?? {},
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
      );

      await videoController.initialize();

      if (_disposed ||
          _currentItem != collectionItem.currentItem ||
          _currentSourceName != collectionItem.currentSourceName) {
        videoController.dispose();
        return;
      }

      playerController.value = AsyncValue.data(videoController);
      _playerStateStreamController.add(videoController.value);
      videoController.addListener(() {
        final value = videoController.value;

        _playerStateStreamController.add(value);
        if (value.isEnded) {
          _onVideoEnds();
        }
      });

      await videoController.seekTo(Duration(seconds: start));
      await videoController.play();

      videoController.setVolume(AppPreferences.volume);
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

      _videoPlayerController?.dispose();
      playerController.value = AsyncValue.error(e, stackTrace);
      _playerStateStreamController.add(VideoPlayerValue.uninitialized());
    }
  }

  void _onVideoEnds() async {
    switch (AppPreferences.videoPlayerSettingEndsAction) {
      case OnVideoEndsAction.playNext:
        nextItem();
      case OnVideoEndsAction.playAgain:
        if (_videoPlayerController != null) {
          final videoController = _videoPlayerController!;
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
      changeCollectionCurentItem(shuffledPosition);
      return;
    }

    final currentIndex = _currentItem ?? 0;
    if (currentIndex >= mediaItems.length - 1) return;

    final nextIndex = currentIndex + 1;
    changeCollectionCurentItem(nextIndex);
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
    changeCollectionCurentItem(prevIndex);
  }

  Future<void> _loadSubtitles(MediaCollectionItem collectionItem) async {
    if (_currentSources == null) {
      return;
    }

    final currentSources = _currentSources!;

    subtitleController.value = AsyncValue.loading();

    final itemIdx = collectionItem.currentItem;
    _currentSubtitleName = collectionItem.currentSubtitleName;

    if (_currentSubtitleName == null) {
      subtitleController.value = AsyncValue.data(null);
      return;
    }

    final cachedSub = _subsCache.get(
      SubCacheKey(itemIdx, _currentSubtitleName!),
    );
    if (cachedSub != null) {
      subtitleController.value = AsyncValue.data(cachedSub);
      return;
    }

    final subtitles = currentSources
        .where((s) => s.kind == FileKind.subtitle)
        .toList();

    final subtitle =
        subtitles.firstWhereOrNull((s) => s.description == _currentSubtitleName)
            as MediaFileItemSource?;

    if (subtitle == null) {
      subtitleController.value = AsyncValue.data(null);
      return;
    }

    try {
      logger.info("Loading subtitle: $subtitle");

      // Use the subtitle worker to parse subtitle in isolate
      final link = await subtitle.link;
      final controller = await _subtitleWorker.parseSubtitle(
        link.toString(),
        subtitle.headers,
      );

      // Check if the request is still valid
      if (_disposed ||
          _currentItem != collectionItem.currentItem ||
          _currentSubtitleName != collectionItem.currentSubtitleName) {
        return;
      }

      _subsCache.put(SubCacheKey(itemIdx, _currentSubtitleName!), controller);
      subtitleController.value = AsyncValue.data(controller);

      logger.info("Subtitle loaded successfully");
    } catch (e, stackTrace) {
      logger.severe("Fail to load subtitle", e, stackTrace);
      subtitleController.value = AsyncValue.error(e, stackTrace);
    }
  }
}

class VideoContentControllerInheritedWidget extends InheritedWidget {
  final VideoContentController controller;

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

VideoContentController videoContentController(BuildContext context) =>
    VideoContentControllerInheritedWidget.of(context).controller;
