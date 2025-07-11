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
import 'package:strumok/content/video/video_content_tv_view.dart';
import 'package:strumok/content/video/video_player_provider.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/trace.dart';
import 'package:strumok/utils/tv.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/visual.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

extension PlayerExt on Player {
  void safeSeek(Duration position) {
    if (position <= Duration.zero) {
      seek(Duration.zero);
    } else if (position < state.duration) {
      seek(position);
    }
  }
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
  final _player = Player();
  late final VideoController _videoController;
  late ProviderSubscription _subscription;
  late List<StreamSubscription> _streamSubscriptions;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final List<int> _shuffledPositions = [];

  List<ContentMediaItemSource> _currentSources = const [];
  @override
  void initState() {
    super.initState();

    if (_player.platform is NativePlayer) {
      final platform = _player.platform as NativePlayer;
      platform.setProperty("force-seekable", "yes");

      final userLang = ref.read(userLanguageSettingProvider);
      final alang = "$userLang,en";
      platform.setProperty("alang", alang);
      platform.setProperty("vlang", alang);
    }

    _videoController = TVDetector.isTV
        ? VideoController(
            _player,
            configuration: const VideoControllerConfiguration(
              vo: "gpu",
              hwdec: "mediacodec",
              enableHardwareAcceleration: true,
            ),
          )
        : VideoController(_player);

    final provider = collectionItemProvider(widget.contentDetails);
    final notifier = ref.read(provider.notifier);

    // track current episode
    _subscription = ref.listenManual<AsyncValue<MediaCollectionItem>>(
      provider,
      (previous, next) async {
        final previousValue = previous?.value;
        final nextValue = next.value;

        if (nextValue == null) {
          return;
        }

        if (previousValue?.currentItem != nextValue.currentItem ||
            previousValue?.currentSourceName != nextValue.currentSourceName) {
          await _playMediaItems(nextValue);
        } else if (previousValue?.currentSubtitleName !=
            nextValue.currentSubtitleName) {
          ref
              .read(currentSubtitleControllerProvider.notifier)
              .setSubtitles(_currentSources, nextValue);
        }
      },
      fireImmediately: true,
    );

    // track video position and duration
    _streamSubscriptions = [
      // track video end
      _player.stream.completed.listen((event) {
        if (event) {
          _onVideoEnds();
        }
      }),
      _player.stream.position.listen((event) {
        final position = event.inSeconds;
        final duration = _player.state.duration.inSeconds;

        if (position > 0 && duration > 0) {
          notifier.setCurrentPosition(position, duration);
        }
      }),
      _player.stream.volume.listen((event) => AppPreferences.volume = event),
      _player.stream.error.listen((event) {
        ref.read(playerErrorsProvider.notifier).addError(event);
        logger.e("[player error]: $event");
      }),
    ];

    _player.setVolume(AppPreferences.volume);

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _playMediaItems(MediaCollectionItem progress) async {
    try {
      final itemIdx = progress.currentItem;
      final sourceName = progress.currentSourceName;

      isLoading.value = true;
      await _player.stop();

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

      final media = Media(
        link.toString(),
        httpHeaders: video.headers,
        start: Duration(seconds: start),
      );

      logger.i("Starting video: $media");
      isLoading.value = false;
      _currentSources = sources;

      await _player.open(media);

      ref
          .read(currentSubtitleControllerProvider.notifier)
          .setSubtitles(_currentSources, progress);
    } catch (error, stackTrace) {
      if (e is ContentSuppliersException) {
        traceError(
          error: e,
          stackTrace: stackTrace,
          message: "fail to start video",
        );
      } else {
        logger.e("Fail to start video", error: e, stackTrace: stackTrace);
      }

      _player.stop();

      // show error snackbar
      if (mounted) {
        final error = AppLocalizations.of(context)!.videoSourceFailed;

        ref.read(playerErrorsProvider.notifier).addError(error);

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
          );
      }
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

    for (var sub in _streamSubscriptions) {
      sub.cancel();
    }
    _subscription.close();
    _player.dispose();

    super.dispose();
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
        await _player.seek(Duration.zero);
        await _player.play();
      case OnVideoEndsAction.doNothing: // do nothing
    }
  }

  void selectItem(int itemIdx) {
    if (!_isValidItemIdx(itemIdx)) {
      return;
    }

    final notifier = ref.read(
      collectionItemProvider(widget.contentDetails).notifier,
    );

    notifier.setCurrentItem(itemIdx);
  }

  bool _isValidItemIdx(int itemIdx) {
    return itemIdx < widget.mediaItems.length && itemIdx >= 0;
  }

  int _getShuffledPosition() {
    if (_shuffledPositions.isEmpty) {
      final positions = List.generate(widget.mediaItems.length, (i) => i);
      final rng = Random();
      while (positions.isNotEmpty) {
        _shuffledPositions.add(
          positions.removeAt(rng.nextInt(positions.length)),
        );
      }
    }

    return _shuffledPositions.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    if (TVDetector.isTV) {
      return _buildTvView();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return _buildMobileView();
    }

    return _buildDesktopView();
  }

  Widget _buildTvView() {
    return VideoContentTVView(
      player: _player,
      videoController: _videoController,
    );
  }

  Widget _buildMobileView() {
    return VideoContentMobileView(
      player: _player,
      videoController: _videoController,
    );
  }

  Widget _buildDesktopView() {
    return VideoContentDesktopView(
      player: _player,
      videoController: _videoController,
    );
  }
}
