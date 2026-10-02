import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/video_backend/hls_proxy_server.dart';
import 'package:strumok/video_backend/video_backend.dart';
import 'package:strumok/video_backend/tracks.dart';

class MediaKitVideoBackend extends VideoBackend {
  media_kit.Player? _player;
  media_kit_video.VideoController? _videoController;
  final List<StreamSubscription> _streamSubscriptions = [];
  final List<StreamSubscription> _initializationStreamSubscriptions = [];

  final HLSProxyServer _hlsProxyServer = HLSProxyServer(port: 16888);

  static const _eofTolerance = Duration(seconds: 5);
  String? _lastError;

  bool _disposed = false;
  Completer? _initCompleter;

  static void registerWith() {
    media_kit.MediaKit.ensureInitialized();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;

    final subscriptions = [
      ..._initializationStreamSubscriptions,
      ..._streamSubscriptions,
    ];
    _initializationStreamSubscriptions.clear();
    _streamSubscriptions.clear();

    if (_initCompleter?.isCompleted == false) {
      _initCompleter!.completeError(StateError("Video backend disposed"));
    }

    super.dispose();

    await Future.wait(subscriptions.map((e) => e.cancel()));
    await _hlsProxyServer.stop();
    await _player?.dispose();

    _player = null;
    _videoController = null;
  }

  /// Completes normally if the backend gets disposed before initialization finishes.
  @override
  Future<void> initialize(
    Uri link, {
    Map<String, String>? headers,
    Duration? start,
    Set<String>? preferredLanguage,
    bool hlsProxy = false,
  }) async {
    if (_disposed) {
      return;
    }

    try {
      await _initialize(
        link,
        headers: headers,
        start: start,
        preferredLanguage: preferredLanguage,
        hlsProxy: hlsProxy,
      );
    } catch (_) {
      // pending player calls fail once dispose() runs mid-initialization
      if (_disposed) {
        return;
      }
      rethrow;
    }
  }

  Future<void> _initialize(
    Uri link, {
    Map<String, String>? headers,
    Duration? start,
    Set<String>? preferredLanguage,
    bool hlsProxy = false,
  }) async {
    if (_player != null) {
      throw StateError("Video backend already initialized");
    }

    if (hlsProxy) {
      link = _hlsProxyServer.masterUrl(link);
      await _hlsProxyServer.start();

      if (_disposed) {
        await _hlsProxyServer.stop();
        return;
      }
    }

    final player = media_kit.Player(
      configuration: media_kit.PlayerConfiguration(
        logLevel: media_kit.MPVLogLevel.v,
      ),
    );

    _player = player;

    final nativePlayer = player.platform as media_kit.NativePlayer;
    await nativePlayer.setProperty("force-seekable", "yes");

    // optimization for smoother playback and avoid frame drops
    await nativePlayer.setProperty("framedrop", "no");
    await nativePlayer.setProperty('video-sync', 'audio');
    await nativePlayer.setProperty('cache', 'yes');
    await nativePlayer.setProperty(
      'demuxer-max-bytes',
      '33554432',
    ); // 32 MB buffer limit
    await nativePlayer.setProperty(
      'demuxer-max-back-bytes',
      '16777216',
    ); // 16 MB back-buffer

    // Set preferred audio language
    if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
      await nativePlayer.setProperty("alang", preferredLanguage.join(","));
      await nativePlayer.setProperty("vlang", preferredLanguage.join(","));
    }

    media_kit_video.VideoController videoController;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      media_kit_video.VideoControllerConfiguration configuration =
          switch (androidInfo.hardware) {
            "amlogic" => media_kit_video.VideoControllerConfiguration(
              hwdec: "mediacodec",
              vo: "gpu",
            ),
            _ => media_kit_video.VideoControllerConfiguration(
              hwdec: "mediacodec",
              vo: "mediacodec_embed",
            ),
          };

      videoController = media_kit_video.VideoController(
        player,
        configuration: configuration,
      );
    } else {
      videoController = media_kit_video.VideoController(player);
    }

    _videoController = videoController;

    // --------------------------------------------------
    // await general stream info
    _streamSubscriptions.add(
      player.stream.log.listen((playerLog) {
        logger.fine("[media_kit] ${playerLog.prefix} ${playerLog.text}");
      }),
    );

    Completer completer = initializationCompleter(player);

    // --------------------------------------------------

    await player.open(
      media_kit.Media(link.toString(), httpHeaders: headers, start: start),
    );

    await completer.future;

    if (_disposed) {
      return;
    }

    // --------------------------------------------------
    // subscribe on updates

    _streamSubscriptions.add(
      player.stream.duration.listen((event) {
        value = value.copyWith(duration: event);
      }),
    );

    _streamSubscriptions.add(
      player.stream.rate.listen((event) {
        value = value.copyWith(playbackSpeed: event);
      }),
    );

    _streamSubscriptions.add(
      player.stream.volume.listen((event) {
        value = value.copyWith(volume: event / 100);
      }),
    );

    _streamSubscriptions.add(
      player.stream.position.listen((event) {
        value = value.copyWith(position: event);
      }),
    );

    _streamSubscriptions.add(
      player.stream.playing.listen((event) async {
        value = value.copyWith(isPlaying: event);
      }),
    );

    _streamSubscriptions.add(
      player.stream.buffering.listen((event) async {
        value = value.copyWith(isBuffering: event);
      }),
    );

    _streamSubscriptions.add(
      player.stream.buffer.listen((event) async {
        value = value.copyWith(buffered: event);
      }),
    );

    _streamSubscriptions.add(
      player.stream.track.listen((event) async {
        value = value.copyWith(
          currentAudioTrackId: event.audio.id,
          currentVideoTrackId: event.video.id,
        );
      }),
    );

    _streamSubscriptions.add(
      player.stream.error.listen((event) {
        logger.warning("[media_kit] $event");
        _lastError = event;
      }),
    );

    _streamSubscriptions.add(
      player.stream.completed.listen((completed) {
        if (!completed) {
          value = value.copyWith(isEnded: false);
          return;
        }

        // mpv sets eof-reached also when a segment/stream fails to load
        final duration = value.duration;
        final unexpectedEof =
            duration > Duration.zero &&
            duration - value.position > _eofTolerance;

        if (unexpectedEof) {
          value = value.copyWith(
            isPlaying: false,
            hasError: true,
            error: _lastError ?? "Playback stopped unexpectedly",
          );
        } else {
          value = value.copyWith(isEnded: true);
        }
      }),
    );
  }

  Completer initializationCompleter(media_kit.Player player) {
    int? width;
    int? height;
    Duration? duration;
    media_kit.Tracks? tracks;

    final completer = Completer();
    _initCompleter = completer;

    void notify() {
      if (!completer.isCompleted) {
        if (width != null &&
            height != null &&
            duration != null &&
            tracks != null) {
          value = VideoBackendState(
            isInitialized: true,
            isPlaying: true,
            isEnded: false,
            duration: duration!,
            audioTracks: _convertAudioTracks(tracks!),
            videoTracks: _convertVideoTracks(tracks!),
            currentAudioTrackId: player.state.track.audio.id,
            currentVideoTrackId: player.state.track.video.id,
            aspectRatio: width!.toDouble() / height!.toDouble(),
          );

          for (final s in _initializationStreamSubscriptions) {
            s.cancel();
          }
          _initializationStreamSubscriptions.clear();

          completer.complete();
        }
      }
    }

    _initializationStreamSubscriptions.add(
      player.stream.error.listen((event) async {
        logger.warning("[media_kit] $event");
        if (!completer.isCompleted) {
          for (final s in _initializationStreamSubscriptions) {
            s.cancel();
          }
          _initializationStreamSubscriptions.clear();

          completer.completeError(event);
        }
      }),
    );

    _initializationStreamSubscriptions.add(
      player.stream.duration.listen((event) {
        duration = event;
        if (event > Duration.zero) {
          notify();
        }
      }),
    );

    _initializationStreamSubscriptions.add(
      player.stream.videoParams.listen((event) {
        width = event.dw;
        height = event.dh;
        if ((width ?? 0) > 0 && (height ?? 0) > 0) {
          notify();
        }
      }),
    );

    _initializationStreamSubscriptions.add(
      player.stream.tracks.listen((event) {
        tracks = event;
        notify();
      }),
    );

    return completer;
  }

  @override
  Widget buildVideoWidget() {
    if (_videoController == null) {
      throw StateError('VideoPlayer not initialized or disposed');
    }

    return media_kit_video.Video(
      controller: _videoController!,
      controls: NoVideoControls,
      pauseUponEnteringBackgroundMode: false,
    );
  }

  /// Starts the video playback.
  @override
  Future<void> play() async {
    return _player?.play();
  }

  /// Stops the video playback.
  @override
  Future<void> pause() async {
    return _player?.pause();
  }

  /// Sets the volume to a range between 0.0 and 1.0.
  @override
  Future<void> setVolume(double volume) async {
    return _player?.setVolume(volume * 100);
  }

  /// Sets the video position to a [Duration] from the start.
  @override
  Future<void> seekTo(Duration position) async {
    return _player?.seek(position);
  }

  /// Sets the playback speed to a [speed] value indicating the playback rate.
  @override
  Future<void> setPlaybackSpeed(double speed) async {
    return _player?.setRate(speed);
  }

  @override
  Future<void> setAudioTrack(String? id) async {
    final player = _player;

    if (player == null) {
      return;
    }

    final tracks = player.state.tracks;

    // Find the audio track by ID
    for (final track in tracks.audio) {
      if (track.id == id) {
        player.setAudioTrack(track);
        break;
      }
    }
  }

  @override
  Future<void> setVideoTrack(String? id) async {
    final player = _player;

    if (player == null) {
      return;
    }

    final tracks = player.state.tracks;

    // Find the video track by ID
    for (final track in tracks.video) {
      if (track.id == id) {
        player.setVideoTrack(track);
        break;
      }
    }
  }

  @override
  Future<void> setEquilizer(List<double> bands) async {
    if (_player == null) {
      return;
    }

    final nativePlayer = _player!.platform as media_kit.NativePlayer;

    final audioFilter = AppConstances.equalizerBandsFreq
        .mapIndexed((idx, freq) {
          final gain = bands[idx].toInt();
          return 'equalizer=f=$freq:width_type=o:width=1:g=$gain';
        })
        .join(",");

    nativePlayer.setProperty("af", audioFilter);
  }

  /// Steps forward by one frame.
  @override
  Future<void> frameStepForward() async {
    final player = _player;
    if (player == null) return;

    final nativePlayer = player.platform as media_kit.NativePlayer;
    await nativePlayer.command(["frame-step"]);
  }

  /// Steps backward by one frame.
  @override
  Future<void> frameStepBackward() async {
    final player = _player;
    if (player == null) return;

    final nativePlayer = player.platform as media_kit.NativePlayer;
    await nativePlayer.command(["frame-back-step"]);
  }

  List<VideoTrack> _convertVideoTracks(media_kit.Tracks tracks) {
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

  List<AudioTrack> _convertAudioTracks(media_kit.Tracks tracks) {
    return tracks.audio.map((t) {
      String name = t.id;

      if (t.title != null) {
        name = t.title!;
      } else if (t.language != null) {
        name = t.language!;
      } else if (t.bitrate != null) {
        final formatBitrate = formatBytes(t.bitrate!);
        name = "${t.id}. ${formatBitrate}it/s";
      }

      return AudioTrack(id: t.id, name: name);
    }).toList();
  }
}
