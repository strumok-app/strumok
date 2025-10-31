import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/video_backend/extension.dart';
import 'package:strumok/video_backend/tracks.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// package:media_kit implementation of [VideoPlayerPlatform].
///
/// References:
/// * https://pub.dev/packages/media_kit
/// * https://github.com/media-kit/media-kit
///
class MediaKitVideoPlayerPlatform extends VideoPlayerPlatform
    implements VideoPlayerPlatformExtend {
  // The implementation uses [Player.hashCode] as texture ID.
  final _players = HashMap<int, media_kit.Player>();
  final _completers = HashMap<int, Completer<void>>();
  final _videoControllers = HashMap<int, VideoController>();
  final _streamControllers = HashMap<int, StreamController<VideoEvent>>();
  final _streamSubscriptions = HashMap<int, List<StreamSubscription>>();
  final _tracks = HashMap<int, media_kit.Tracks>();

  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith() {
    media_kit.MediaKit.ensureInitialized();
    VideoPlayerPlatform.instance = MediaKitVideoPlayerPlatform();
  }

  /// Initializes the platform interface and disposes all existing players.
  ///
  /// This method is called when the plugin is first initialized and on every full restart.
  @override
  Future<void> init() async {
    for (final textureId in _players.keys) {
      await dispose(textureId);
    }

    _players.clear();
    _videoControllers.clear();
    _streamControllers.clear();
    _streamSubscriptions.clear();
  }

  /// Clears one video.
  @override
  Future<void> dispose(int textureId) async {
    await _players[textureId]?.dispose();

    await _streamControllers[textureId]?.close();
    await Future.wait(
      _streamSubscriptions[textureId]?.map((e) => e.cancel()) ?? [],
    );

    _players.remove(textureId);
    _videoControllers.remove(textureId);
    _streamControllers.remove(textureId);
    _streamSubscriptions.remove(textureId);
    _tracks.remove(textureId);
  }

  /// Creates an instance of a video player and returns its textureId.
  @override
  Future<int?> create(DataSource dataSource) async {
    final player = media_kit.Player(
      configuration: media_kit.PlayerConfiguration(
        logLevel: media_kit.MPVLogLevel.v,
      ),
    );
    final completer = Completer();

    final nativePlayer = player.platform as media_kit.NativePlayer;
    nativePlayer.setProperty("force-seekable", "yes");

    VideoController videoController;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      VideoControllerConfiguration configuration =
          switch (androidInfo.hardware) {
            "amlogic" => VideoControllerConfiguration(
              hwdec: "mediacodec",
              vo: "gpu",
            ),
            _ => VideoControllerConfiguration(
              hwdec: "mediacodec",
              vo: "mediacodec_embed",
            ),
          };

      videoController = VideoController(player, configuration: configuration);
    } else {
      videoController = VideoController(player);
    }

    // NOTE: [StreamController] without broadcast buffers events.
    final streamController = StreamController<VideoEvent>();
    final streamSubscriptions = <StreamSubscription>[];

    final textureId = player.hashCode;

    _players[textureId] = player;
    _completers[textureId] = completer;
    _videoControllers[textureId] = videoController;
    _streamControllers[textureId] = streamController;
    _streamSubscriptions[textureId] = streamSubscriptions;

    // --------------------------------------------------]
    _initialize(textureId);
    // --------------------------------------------------

    final String resource;
    final Map<String, String> httpHeaders = dataSource.httpHeaders;

    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        final String? asset;
        if (dataSource.package == null) {
          asset = dataSource.asset;
        } else {
          asset = 'packages/${dataSource.package}/${dataSource.asset}';
        }
        resource = 'asset:///$asset';
        break;

      case DataSourceType.network:
      case DataSourceType.file:
      case DataSourceType.contentUri:
        if (dataSource.uri == null) {
          throw ArgumentError('uri must not be null');
        }
        resource = dataSource.uri!;
        break;
    }

    await player.open(
      media_kit.Media(resource, httpHeaders: httpHeaders),
      play: false,
    );

    return textureId;
  }

  /// Returns a Stream of [VideoEventType]s.
  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    if (_streamControllers[textureId] == null) {
      throw StateError(
        'VideoPlayer for textureId $textureId is not found, Check if its disposed.',
      );
    }
    return _streamControllers[textureId]!.stream;
  }

  /// Sets the looping attribute of the video.
  @override
  Future<void> setLooping(int textureId, bool looping) async {
    final playlistMode = looping
        ? media_kit.PlaylistMode.single
        : media_kit.PlaylistMode.none;
    return _players[textureId]?.setPlaylistMode(playlistMode);
  }

  /// Starts the video playback.
  @override
  Future<void> play(int textureId) async {
    return _players[textureId]?.play();
  }

  /// Stops the video playback.
  @override
  Future<void> pause(int textureId) async {
    return _players[textureId]?.pause();
  }

  /// Sets the volume to a range between 0.0 and 1.0.
  @override
  Future<void> setVolume(int textureId, double volume) async {
    // NOTE: [volume] is in the range of 0.0 to 1.0 while [setVolume] expects 0.0 to 100.
    return _players[textureId]?.setVolume(volume * 100);
  }

  /// Sets the video position to a [Duration] from the start.
  @override
  Future<void> seekTo(int textureId, Duration position) async {
    return _players[textureId]?.seek(position);
  }

  /// Sets the playback speed to a [speed] value indicating the playback rate.
  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    return _players[textureId]?.setRate(speed);
  }

  /// Gets the video position as [Duration] from the start.
  @override
  Future<Duration> getPosition(int textureId) async {
    return _players[textureId]?.platform?.state.position ?? Duration.zero;
  }

  /// Returns a widget displaying the video with a given textureId.
  @override
  Widget buildView(int textureId) {
    if (_videoControllers[textureId] == null) {
      throw StateError(
        'VideoPlayer for textureId $textureId is not found, Check if its disposed.',
      );
    }
    return Video(
      key: ValueKey(_videoControllers[textureId]!),
      controller: _videoControllers[textureId]!,
      controls: NoVideoControls,
    );
  }

  /// Sets the audio mode to mix with other sources.
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future.value();

  /// Sets additional options on web.
  @override
  Future<void> setWebOptions(int textureId, VideoPlayerWebOptions options) =>
      Future.value();

  /// Initialize the [Stream]s for a given textureId.
  void _initialize(int textureId) {
    if (_streamSubscriptions[textureId]?.isNotEmpty ?? false) {
      return;
    }

    final player = _players[textureId];
    final completer = _completers[textureId];
    final streamController = _streamControllers[textureId];
    final streamSubscriptions = _streamSubscriptions[textureId];

    if (player != null &&
        completer != null &&
        streamController != null &&
        streamSubscriptions != null) {
      // VideoEventType.initialized

      streamSubscriptions.add(
        player.stream.log.listen((playerLog) {
          logger.fine("[media_kit] ${playerLog.prefix} ${playerLog.text}");
        }),
      );

      int? width;
      int? height;
      Duration? duration;
      media_kit.Tracks? tracks;

      void notify() {
        if (!completer.isCompleted) {
          if (width != null &&
              height != null &&
              duration != null &&
              tracks != null) {
            _tracks[textureId] = tracks!;
            streamController.add(
              VideoEvent(
                eventType: VideoEventType.initialized,
                size: Size(width!.toDouble(), height!.toDouble()),
                duration: player.state.duration,
              ),
            );
            completer.complete();
          }
        }
      }

      streamSubscriptions.add(
        player.stream.duration.listen((event) {
          if (event > Duration.zero) {
            duration = event;

            if (completer.isCompleted) {
              streamController.add(
                VideoEvent(
                  eventType: VideoEventType.durationUpdate,
                  duration: event,
                ),
              );
            } else {
              notify();
            }
          }
        }),
      );
      streamSubscriptions.add(
        player.stream.videoParams.listen((event) {
          width = event.dw;
          height = event.dh;
          if ((width ?? 0) > 0 && (height ?? 0) > 0) {
            notify();
          }
        }),
      );

      streamSubscriptions.add(
        player.stream.tracks.listen((event) {
          tracks = event;
          notify();
        }),
      );
      // VideoEventType.isPlayingStateUpdate
      streamSubscriptions.add(
        player.stream.playing.listen((event) async {
          await completer.future;
          streamController.add(
            VideoEvent(
              eventType: VideoEventType.isPlayingStateUpdate,
              isPlaying: event,
            ),
          );
        }),
      );
      // VideoEventType.completed
      streamSubscriptions.add(
        player.stream.completed.listen((event) async {
          await completer.future;
          if (event) {
            streamController.add(
              VideoEvent(eventType: VideoEventType.completed),
            );
          }
        }),
      );
      // VideoEventType.bufferingStart
      streamSubscriptions.add(
        player.stream.buffering.listen((event) async {
          await completer.future;
          streamController.add(
            VideoEvent(
              eventType: event
                  ? VideoEventType.bufferingStart
                  : VideoEventType.bufferingEnd,
            ),
          );
        }),
      );
      // VideoEventType.bufferingUpdate
      streamSubscriptions.add(
        player.stream.buffer.listen((event) async {
          await completer.future;
          streamController.add(
            VideoEvent(
              eventType: VideoEventType.bufferingUpdate,
              buffered: [DurationRange(Duration.zero, event)],
              duration: player.state.duration,
            ),
          );
        }),
      );

      streamSubscriptions.add(
        player.stream.error.listen((event) async {
          if (completer.isCompleted) {
            logger.warning("[media_kit] {event}");
          } else {
            streamController.addError(
              PlatformException(code: 'MediaKit Error', message: event),
              StackTrace.empty,
            );
          }
        }),
      );
    }
  }

  @override
  List<AudioTrack> getAllAudioTracks(int textureId) {
    final tracks = _tracks[textureId];

    if (tracks == null) {
      return [];
    }

    return tracks.audio.map((t) {
      String name = t.id;

      if (t.title != null) {
        name = t.language!;
      } else if (t.language != null) {
        name = t.language!;
      } else if (t.samplerate != null) {
        final formatBitrate = formatBytes(t.samplerate!);
        name = "${t.id}. ${formatBitrate}it/s";
      }

      return AudioTrack(id: t.id, name: name);
    }).toList();
  }

  @override
  List<VideoTrack> getAllVideoTracks(int textureId) {
    final tracks = _tracks[textureId];

    if (tracks == null) {
      return [];
    }

    return tracks.video.map((t) {
      return VideoTrack(
        id: t.id,
        height: t.h ?? 0,
        width: t.w ?? 0,
        fps: t.fps,
        samplerate: t.samplerate,
      );
    }).toList();
  }

  @override
  void setCurrentAudioTrack(int textureId, String id) {
    final player = _players[textureId];
    final tracks = _tracks[textureId];

    if (player == null || tracks == null) {
      return;
    }

    // Find the audio track by ID
    for (final track in tracks.audio) {
      if (track.id == id) {
        player.setAudioTrack(track);
        break;
      }
    }
  }

  @override
  void setCurrentVideoTrack(int textureId, String id) {
    final player = _players[textureId];
    final tracks = _tracks[textureId];

    if (player == null || tracks == null) {
      return;
    }

    // Find the video track by ID
    for (final track in tracks.video) {
      if (track.id == id) {
        player.setVideoTrack(track);
        break;
      }
    }
  }

  @override
  String? getCurrentVideoTrackId(int textureId) {
    final player = _players[textureId];
    if (player == null) {
      return null;
    }

    // Get the currently selected video track ID from the player state
    return player.state.track.video.id;
  }

  @override
  String? getCurrentAudioTrackId(int textureId) {
    final player = _players[textureId];
    if (player == null) {
      return null;
    }

    // Get the currently selected audio track ID from the player state
    return player.state.track.audio.id;
  }

  @override
  void setEquilizer(int textureId, List<double> bands) {
    final player = _players[textureId];
    if (player == null) {
      return;
    }

    final nativePlayer = player.platform as media_kit.NativePlayer;

    final audioFilter = AppConstances.equalizerBandsFreq
        .mapIndexed((idx, freq) {
          final gain = bands[idx].toInt();
          return 'equalizer=f=$freq:width_type=o:width=1:g=$gain';
        })
        .join(",");

    nativePlayer.setProperty("af", audioFilter);
  }
}
