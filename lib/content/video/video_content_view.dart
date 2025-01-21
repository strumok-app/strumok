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

const subtitleViewConfiguration = SubtitleViewConfiguration(
  style: TextStyle(
      height: 1.4,
      fontSize: 48.0,
      color: Color(0xffffffff),
      fontWeight: FontWeight.normal,
      backgroundColor: Color(0xaa000000)),
);

extension PlayerExt on Player {
  void safeSeek(Duration position) {
    if (position <= Duration.zero) {
      seek(Duration.zero);
    } else if (position < state.duration) {
      seek(position);
    }
  }
}

class PlayerController {
  final Player player;
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<String>> errors = ValueNotifier([]);

  List<ContentMediaItemSource>? currentSources;
  List<int> shuffledPositions = [];

  final WidgetRef _ref;

  PlayerController({
    required this.player,
    required this.contentDetails,
    required this.mediaItems,
    required WidgetRef ref,
  }) : _ref = ref;

  Future<void> play(ContentProgress progress) async {
    try {
      isLoading.value = true;
      await player.stop();

      final itemIdx = progress.currentItem;
      final sourceName = progress.currentSourceName;
      final subtitleName = progress.currentSubtitleName;

      final item = mediaItems[itemIdx];
      final sources = await item.sources;
      final videos = sources.where((s) => s.kind == FileKind.video).toList();

      var video = sourceName == null
          ? videos.firstOrNull as MediaFileItemSource?
          : videos.firstWhereOrNull((s) => s.description == sourceName) as MediaFileItemSource?;

      if (video == null && sourceName != null) {
        addError("Video source $sourceName not avalaible");
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
        StarVideoPosition.fromFixedPosition => AppPreferences.videoPlayerSettingFixedPosition,
      };

      if (currentItemPosition.length > 0 && start > currentItemPosition.length - 60) {
        start = start - 60;
      } else if (start < 0) {
        start = 0;
      }

      final media = Media(
        link.toString(),
        httpHeaders: video.headers,
        start: Duration(seconds: start),
      );

      isLoading.value = false;
      errors.value = [];

      if (progress.currentItem == itemIdx && progress.currentSourceName == sourceName) {
        logger.i("Starting video: $media");
        await player.open(media);
        currentSources = sources;
      }

      if (progress.currentSubtitleName == subtitleName) {
        await setSubtitle(sourceName);
      }
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
      addError("Fail to start video: $e");
      player.stop();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setSubtitle(String? currentSubtitle) async {
    if (currentSources == null) {
      return;
    }

    if (currentSubtitle == null) {
      await player.setSubtitleTrack(SubtitleTrack.no());
      return;
    }

    final subtitles = currentSources!.where((s) => s.kind == FileKind.subtitle).toList();

    final subtitle = subtitles.firstWhereOrNull((s) => s.description == currentSubtitle) as MediaFileItemSource?;

    if (subtitle != null) {
      await player.setSubtitleTrack(SubtitleTrack.uri(
        subtitle.link.toString(),
        title: subtitle.description,
      ));
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
        await player.seek(Duration.zero);
        await player.play();
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

  void addError(String error) {
    errors.value = [...errors.value, error];
  }

  int _getShuffledPosition() {
    if (shuffledPositions.isEmpty) {
      final positions = List.generate(mediaItems.length, (i) => i);
      final rng = Random();
      while (positions.isNotEmpty) {
        shuffledPositions.add(
          positions.removeAt(rng.nextInt(positions.length)),
        );
      }
    }

    return shuffledPositions.removeAt(0);
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
  final player = Player();
  late final VideoController videoController;
  late final PlayerController playerController;
  late ProviderSubscription subscription;

  @override
  void initState() {
    super.initState();

    traceAction(
      "load_video",
      description: "supplier: ${widget.contentDetails.supplier}, id: ${widget.contentDetails.id}",
    );

    if (player.platform is NativePlayer) {
      (player.platform as NativePlayer).setProperty("force-seekable", "yes");
    }

    videoController = Platform.isAndroid
        ? VideoController(
            player,
            configuration: const VideoControllerConfiguration(
              vo: "mediacodec_embed",
              hwdec: "mediacodec",
            ),
          )
        : VideoController(player);

    playerController = PlayerController(
      contentDetails: widget.contentDetails,
      player: player,
      mediaItems: widget.mediaItems,
      ref: ref,
    );

    final provider = collectionItemProvider(widget.contentDetails);
    final notifier = ref.read(provider.notifier);

    // track current episode
    subscription = ref.listenManual<AsyncValue<MediaCollectionItem>>(
      provider,
      (previous, next) async {
        final previousValue = previous?.value;
        final nextValue = next.value;

        if (nextValue != null) {
          if ((previousValue?.currentItem != nextValue.currentItem ||
              previousValue?.currentSourceName != nextValue.currentSourceName)) {
            await _playMediaItems(nextValue);
          } else if (previousValue?.currentSubtitleName != nextValue.currentSubtitleName) {
            await playerController.setSubtitle(nextValue.currentSubtitleName);
          }
        }
      },
      fireImmediately: true,
    );

    // track video end
    player.stream.completed.listen((event) {
      if (event) {
        playerController.onVideoEnds();
      }
    });

    // track video position and duration
    player.stream.position.listen((event) {
      final position = event.inSeconds;
      final duration = player.state.duration.inSeconds;

      if (position > 0 && duration > 0) {
        notifier.setCurrentPosition(position, duration);
      }
    });

    player.setVolume(AppPreferences.volume);
    player.stream.volume.listen((event) => AppPreferences.volume = event);

    player.stream.error.listen((event) {
      playerController.addError(event);
      logger.e("[player]: $event");
    });

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _playMediaItems(MediaCollectionItem nextValue) async {
    try {
      await playerController.play(nextValue);
    } catch (_) {
      // show error snackbar
      if (mounted) {
        final error = AppLocalizations.of(context)!.videoSourceFailed;
        playerController.addError(error);

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(error),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  @override
  void dispose() {
    subscription.close();
    player.dispose();
    super.dispose();

    if (isMobileDevice()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = switch (Theme.of(context).platform) {
      TargetPlatform.android => TVDetector.isTV ? _renderTvView() : _renderMobileView(),
      TargetPlatform.iOS => _renderMobileView(),
      _ => _renderDesktopView()
    };

    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black,
      child: Stack(
        children: [
          // _renderTvView(),
          view,
          ValueListenableBuilder(
            valueListenable: playerController.isLoading,
            builder: (context, value, child) {
              return value
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }

  Widget _renderTvView() {
    return VideoContentTVView(
      player: player,
      videoController: videoController,
      playerController: playerController,
    );
  }

  Widget _renderMobileView() {
    return VideoContentMobileView(
      player: player,
      videoController: videoController,
      playerController: playerController,
    );
  }

  Widget _renderDesktopView() {
    return VideoContentDesktopView(
      player: player,
      videoController: videoController,
      playerController: playerController,
    );
  }

  // playback callbacks
}
