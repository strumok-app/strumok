import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:strumok/app_localizations.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_item_provider.dart';
import 'package:strumok/content/video/model.dart';
import 'package:strumok/content/video/video_content_desktop_view.dart';
import 'package:strumok/content/video/video_content_mobile_view.dart';
import 'package:strumok/content/video/video_content_tv_controls.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/content/video/video_subtitles.dart';
import 'package:strumok/utils/trace.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/visual.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

extension VideoPlayerValueExt on VideoPlayerValue {
  Duration get lastBuffer => buffered.lastOrNull?.end ?? Duration.zero;
  bool get isEnded =>
      duration > Duration.zero && position >= duration && !isPlaying;
}

class VideoContentView extends ConsumerStatefulWidget {
  static final _key = GlobalKey<VideoContentViewState>();
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  VideoContentView({required this.contentDetails, required this.mediaItems})
    : super(key: _key);

  static VideoContentViewState get currentState => _key.currentState!;
  static ContentDetails get currentContentDetails =>
      (_key.currentWidget as VideoContentView).contentDetails;
  static List<ContentMediaItem> get currentMediaItems =>
      (_key.currentWidget as VideoContentView).mediaItems;

  @override
  ConsumerState<VideoContentView> createState() => VideoContentViewState();
}

class VideoContentViewState extends ConsumerState<VideoContentView> {
  VideoPlayerController? _videoController;
  late ProviderSubscription _providerSub;

  List<int> _shuffledPositions = [];
  List<ContentMediaItemSource> _currentSources = const [];

  final StreamController<VideoPlayerValue> _playerStateSteamController =
      StreamController.broadcast();
  Stream<VideoPlayerValue> get playerStream =>
      _playerStateSteamController.stream;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<EdgeInsets> subtitlePaddings = ValueNotifier(
    EdgeInsets.zero,
  );
  VideoPlayerValue get playerState =>
      _videoController?.value ?? VideoPlayerValue.uninitialized();

  @override
  void initState() {
    super.initState();

    final provider = collectionItemProvider(widget.contentDetails);

    // track current episode
    _providerSub = ref.listenManual<AsyncValue<MediaCollectionItem>>(provider, (
      previous,
      next,
    ) async {
      final previousValue = previous?.value;
      final nextValue = next.value;

      if (nextValue == null) {
        return;
      }

      if (previousValue?.currentItem != nextValue.currentItem ||
          previousValue?.currentSourceName != nextValue.currentSourceName) {
        await _playMediaItem(nextValue);
      } else if (previousValue?.currentSubtitleName !=
          nextValue.currentSubtitleName) {
        ref
            .read(currentSubtitleControllerProvider.notifier)
            .setSubtitles(_currentSources, nextValue);
      }
    }, fireImmediately: true);

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    _providerSub.close();
    _videoController?.dispose();

    super.dispose();
  }

  Future<void> _playMediaItem(MediaCollectionItem progress) async {
    try {
      _videoController?.dispose();

      final itemIdx = progress.currentItem;
      final sourceName = progress.currentSourceName;

      isLoading.value = true;

      final item = widget.mediaItems[itemIdx];
      final sources = await item.sources;

      if (progress.currentItem != itemIdx ||
          progress.currentSourceName != sourceName) {
        return;
      }

      final videos = sources.where((s) => s.kind == FileKind.video).toList();

      var video = sourceName == null
          ? videos.firstOrNull as MediaFileItemSource?
          : videos.firstWhereOrNull((s) => s.description == sourceName)
                as MediaFileItemSource?;

      if (video == null && sourceName != null) {
        ref
            .read(playerErrorsProvider.notifier)
            .addError("Video source $sourceName not avalaible");
        video = videos.firstOrNull as MediaFileItemSource?;
      }

      if (video == null) {
        return;
      }

      final link = await video.link;

      if (!mounted) {
        return;
      }

      if (progress.currentItem != itemIdx ||
          progress.currentSourceName != sourceName) {
        return;
      }

      final startPosition = AppPreferences.videoPlayerSettingStarFrom;

      final currentItemPosition = progress.currentMediaItemPosition;
      int start = switch (startPosition) {
        StarVideoPosition.fromBeginning => 0,
        StarVideoPosition.fromRemembered => progress.currentPosition,
        StarVideoPosition.fromFixedPosition =>
          AppPreferences.videoPlayerSettingFixedPosition,
      };

      if (currentItemPosition.length > 0 &&
          start > currentItemPosition.length - 60) {
        start = start - 60;
      } else if (start < 0) {
        start = 0;
      }

      ref.read(playerErrorsProvider.notifier).reset();

      // final media = Media(
      //   link.toString(),
      //   httpHeaders: video.headers,
      //   start: Duration(seconds: start),
      // );

      // logger.i("Starting video: $media");
      isLoading.value = false;
      _currentSources = sources;

      // await _player.open(media);
      final videoController = VideoPlayerController.networkUrl(
        link,
        httpHeaders: video.headers ?? {},
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: true,
          mixWithOthers: true,
        ),
      );

      videoController.addListener(() {
        final value = videoController.value;
        _playerStateSteamController.add(value);

        if (value.isEnded) {
          _onVideoEnds();
        }
      });

      await videoController.initialize();

      setState(() {
        _videoController = videoController;
      });

      await videoController.seekTo(Duration(seconds: start));
      await videoController.play();

      videoController.setVolume(AppPreferences.volume);

      ref
          .read(currentSubtitleControllerProvider.notifier)
          .setSubtitles(_currentSources, progress);
    } catch (error, stackTrace) {
      if (error is ContentSuppliersException) {
        traceError(
          error: error,
          stackTrace: stackTrace,
          message: "fail to start video",
        );
      } else {
        logger.e("Fail to start video", error: error, stackTrace: stackTrace);
      }

      _videoController?.dispose();

      // show error snackbar
      if (mounted) {
        ref.read(playerErrorsProvider.notifier).addError(error.toString());

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.videoSourceFailed),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  Future<void> play() async {
    await _videoController?.play();
  }

  Future<void> pause() async {
    await _videoController?.pause();
  }

  Future<void> playOrPause() async {
    if (_videoController != null) {
      final controller = _videoController!;
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        await controller.play();
      }
    }
  }

  Future<void> seek(Duration position) async {
    await _videoController?.seekTo(position);
  }

  Future<void> volumeUp() async {
    if (_videoController != null) {
      final controller = _videoController!;
      await controller.setVolume(
        (controller.value.volume + .05).clamp(0.0, 1.0),
      );
    }
  }

  Future<void> volumeDown() async {
    if (_videoController != null) {
      final controller = _videoController!;
      await controller.setVolume(
        (controller.value.volume - .05).clamp(0.0, 1.0),
      );
    }
  }

  void setRate(double speedUpFactor) async {
    _videoController?.setPlaybackSpeed(speedUpFactor);
  }

  Future<void> setVolume(double volume) async {
    await _videoController?.setVolume(volume);
  }

  void nextItem() {
    if (AppPreferences.videoPlayerSettingShuffleMode) {
      final shuffledPosition = _getShuffledPosition();
      selectItem(shuffledPosition);
      return;
    }

    final value = ref
        .read(collectionItemProvider(widget.contentDetails))
        .value!;

    // asyncValue.whenData((value) {
    selectItem(value.currentItem + 1);
    // });
  }

  void prevItem() {
    final value = ref
        .read(collectionItemProvider(widget.contentDetails))
        .value!;

    // asyncValue.whenData((value) {
    selectItem(value.currentItem - 1);
    // });
  }

  void _onVideoEnds() async {
    switch (AppPreferences.videoPlayerSettingEndsAction) {
      case OnVideoEndsAction.playNext:
        nextItem();
      case OnVideoEndsAction.playAgain:
      // await _player.seek(Duration.zero);
      // await _player.play();
      case OnVideoEndsAction.doNothing: // do nothing
    }
  }

  void selectItem(int itemIdx) {
    if (!_isValidItemIdx(itemIdx)) {
      return;
    }

    ref
        .read(collectionItemProvider(widget.contentDetails).notifier)
        .setCurrentItem(itemIdx);

    ref.read(subtitlesOffsetProvider.notifier).setOffset(0);
  }

  bool _isValidItemIdx(int itemIdx) {
    return itemIdx < widget.mediaItems.length && itemIdx >= 0;
  }

  int _getShuffledPosition() {
    if (_shuffledPositions.isEmpty) {
      final shuffledPositions = List.generate(
        widget.mediaItems.length,
        (i) => i,
      );
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

  @override
  Widget build(BuildContext context) {
    ref.watch(playerErrorsProvider);

    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      child: Stack(
        children: [
          if (_videoController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
          PlayerSubtitles(),
          Positioned.fill(child: _buildControlsView()),
          ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (context, value, child) {
              return value
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlsView() {
    if (TVDetector.isTV) {
      return AndroidTVControls();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return VideoContentMobileView();
    }

    return VideoContentDesktopView();
  }
}
