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
import 'package:subtitle/subtitle.dart';

extension PlayerExt on Player {
  void safeSeek(Duration position) {
    if (position <= Duration.zero) {
      seek(Duration.zero);
    } else if (position < state.duration) {
      seek(position);
    }
  }
}

// TODO: this smells bad, need to figureout how to make it better
class PlayerController {
  final Player _player;
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  List<ContentMediaItemSource>? _currentSources;
  final List<int> _shuffledPositions = [];

  final WidgetRef _ref;

  PlayerController({
    required Player player,
    required this.contentDetails,
    required this.mediaItems,
    required WidgetRef ref,
  }) : _player = player,
       _ref = ref;

  Future<void> play(ContentProgress progress) async {
    try {
      isLoading.value = true;
      await _player.stop();

      final itemIdx = progress.currentItem;
      final sourceName = progress.currentSourceName;

      final item = mediaItems[itemIdx];
      final sources = await item.sources;
      final videos = sources.where((s) => s.kind == FileKind.video).toList();

      var video =
          sourceName == null
              ? videos.firstOrNull as MediaFileItemSource?
              : videos.firstWhereOrNull((s) => s.description == sourceName)
                  as MediaFileItemSource?;

      if (video == null && sourceName != null) {
        _ref
            .read(playerErrorsProvider.notifier)
            .addError("Video source $sourceName not avalaible");
        video = videos.firstOrNull as MediaFileItemSource?;
      }

      if (video == null) {
        throw Exception("No avalaible video sources");
      }

      final link = await video.link;

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

      final media = Media(
        link.toString(),
        httpHeaders: video.headers,
        start: Duration(seconds: start),
      );

      _ref.read(playerErrorsProvider.notifier).reset();

      if (progress.currentItem == itemIdx &&
          progress.currentSourceName == sourceName) {
        logger.i("Starting video: $media");
        await _player.open(media);
        isLoading.value = false;
        _currentSources = sources;
      }

      await setSubtitle(progress);
    } on Exception catch (e, stackTrace) {
      if (e is ContentSuppliersException) {
        traceError(
          error: e,
          stackTrace: stackTrace,
          message: "fail to start video",
        );
      } else {
        logger.e("Fail to start video", error: e, stackTrace: stackTrace);
      }
      _ref
          .read(playerErrorsProvider.notifier)
          .addError("Fail to start video: $e");
      _player.stop();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setSubtitle(ContentProgress progress) async {
    final itemIdx = progress.currentItem;
    final currentSubtitle = progress.currentSubtitleName;

    if (currentSubtitle == null) {
      _ref.read(currentSubtitleControllerProvider.notifier).setController(null);
      return;
    }

    final subtitles =
        _currentSources!.where((s) => s.kind == FileKind.subtitle).toList();
    final subtitle =
        subtitles.firstWhereOrNull((s) => s.description == currentSubtitle)
            as MediaFileItemSource?;

    if (subtitle != null) {
      final link = await subtitle.link;

      if (progress.currentItem == itemIdx &&
          currentSubtitle == progress.currentSubtitleName) {
        logger.i("Subtitle: $subtitle");

        final controller = SubtitleController(
          provider: NetworkSubtitle(link, headers: subtitle.headers),
        );
        await controller.initial();

        _ref
            .read(currentSubtitleControllerProvider.notifier)
            .setController(controller);
      }
    }
  }

  void nextItem() {
    if (AppPreferences.videoPlayerSettingShuffleMode) {
      final shuffledPosition = _getShuffledPosition();
      selectItem(shuffledPosition);
      return;
    }

    final asyncValue = _ref.read(collectionItemProvider(contentDetails));

    asyncValue.whenData((value) {
      selectItem(value.currentItem + 1);
    });
  }

  void prevItem() {
    final asyncValue = _ref.read(collectionItemProvider(contentDetails));

    asyncValue.whenData((value) {
      selectItem(value.currentItem - 1);
    });
  }

  void onVideoEnds() async {
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

    final notifier = _ref.read(collectionItemProvider(contentDetails).notifier);

    notifier.setCurrentItem(itemIdx);
  }

  bool _isValidItemIdx(int itemIdx) {
    return itemIdx < mediaItems.length && itemIdx >= 0;
  }

  int _getShuffledPosition() {
    if (_shuffledPositions.isEmpty) {
      final positions = List.generate(mediaItems.length, (i) => i);
      final rng = Random();
      while (positions.isNotEmpty) {
        _shuffledPositions.add(
          positions.removeAt(rng.nextInt(positions.length)),
        );
      }
    }

    return _shuffledPositions.removeAt(0);
  }
}

class VideoContentView extends ConsumerStatefulWidget {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  const VideoContentView({
    super.key,
    required this.contentDetails,
    required this.mediaItems,
  });

  @override
  ConsumerState<VideoContentView> createState() => _VideoContentViewState();
}

class _VideoContentViewState extends ConsumerState<VideoContentView> {
  final _player = Player();
  late final VideoController _videoController;
  late final PlayerController _playerController;
  late ProviderSubscription _subscription;
  late List<StreamSubscription> _streamSubscriptions;

  @override
  void initState() {
    super.initState();

    if (_player.platform is NativePlayer) {
      var platform = _player.platform as NativePlayer;
      platform.setProperty("force-seekable", "yes");
    }

    _videoController =
        Platform.isAndroid
            ? VideoController(
              _player,
              configuration: const VideoControllerConfiguration(
                vo: "mediacodec_embed",
                hwdec: "mediacodec",
              ),
            )
            : VideoController(_player);

    _playerController = PlayerController(
      contentDetails: widget.contentDetails,
      player: _player,
      mediaItems: widget.mediaItems,
      ref: ref,
    );

    final provider = collectionItemProvider(widget.contentDetails);
    final notifier = ref.read(provider.notifier);

    // track current episode
    _subscription = ref.listenManual<AsyncValue<MediaCollectionItem>>(
      provider,
      (previous, next) async {
        final previousValue = previous?.value;
        final nextValue = next.value;

        if (nextValue != null) {
          if ((previousValue?.currentItem != nextValue.currentItem ||
              previousValue?.currentSourceName !=
                  nextValue.currentSourceName)) {
            await _playMediaItems(nextValue);
          } else if (previousValue?.currentSubtitleName !=
              nextValue.currentSubtitleName) {
            await _playerController.setSubtitle(nextValue);
          }
        }
      },
      fireImmediately: true,
    );

    // track video position and duration

    _streamSubscriptions = [
      // track video end
      _player.stream.completed.listen((event) {
        if (event) {
          _playerController.onVideoEnds();
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
        logger.e("[player]: $event");
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

  Future<void> _playMediaItems(MediaCollectionItem nextValue) async {
    try {
      await _playerController.play(nextValue);
    } catch (_) {
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

  @override
  Widget build(BuildContext context) {
    Widget view;
    if (TVDetector.isTV) {
      view = _renderTvView();
    } else if (Platform.isAndroid || Platform.isIOS) {
      view = _renderMobileView();
    } else {
      view = _renderDesktopView();
    }

    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      child: Stack(
        children: [
          view,
          ValueListenableBuilder(
            valueListenable: _playerController.isLoading,
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

  Widget _renderTvView() {
    return VideoContentTVView(
      player: _player,
      videoController: _videoController,
      playerController: _playerController,
    );
  }

  Widget _renderMobileView() {
    return VideoContentMobileView(
      player: _player,
      videoController: _videoController,
      playerController: _playerController,
    );
  }

  Widget _renderDesktopView() {
    return VideoContentDesktopView(
      player: _player,
      videoController: _videoController,
      playerController: _playerController,
    );
  }

  // playback callbacks
}
