import 'package:flutter/widgets.dart';
import 'package:strumok/video_backend/media_kit.dart';
import 'package:strumok/video_backend/tracks.dart';

class VideoBackendState {
  final bool isBuffering;
  final bool isInitialized;
  final bool isPlaying;
  final bool isEnded;

  final bool hasError;
  final String? error;

  final Duration buffered;
  final Duration position;
  final Duration duration;

  final double volume;
  final double playbackSpeed;

  final List<VideoTrack> videoTracks;
  final List<AudioTrack> audioTracks;
  final String? currentVideoTrackId;
  final String? currentAudioTrackId;

  final double aspectRatio;

  bool get showBuffering => (isBuffering || !isInitialized) && !hasError;

  const VideoBackendState({
    this.isBuffering = false,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isEnded = false,
    this.hasError = false,
    this.error,
    this.buffered = Duration.zero,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.videoTracks = const [],
    this.audioTracks = const [],
    this.currentVideoTrackId,
    this.currentAudioTrackId,
    this.aspectRatio = 1,
  });

  VideoBackendState copyWith({
    bool? isBuffering,
    bool? isInitialized,
    bool? isPlaying,
    bool? isEnded,
    bool? hasError,
    String? error,
    Duration? buffered,
    Duration? position,
    Duration? duration,
    double? volume,
    double? playbackSpeed,
    List<VideoTrack>? videoTracks,
    List<AudioTrack>? audioTracks,
    String? currentVideoTrackId,
    String? currentAudioTrackId,
    double? aspectRatio,
  }) {
    return VideoBackendState(
      isBuffering: isBuffering ?? this.isBuffering,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isEnded: isEnded ?? this.isEnded,
      hasError: hasError ?? this.hasError,
      error: error ?? this.error,
      buffered: buffered ?? this.buffered,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      videoTracks: videoTracks ?? this.videoTracks,
      audioTracks: audioTracks ?? this.audioTracks,
      currentVideoTrackId: currentVideoTrackId ?? this.currentVideoTrackId,
      currentAudioTrackId: currentAudioTrackId ?? this.currentAudioTrackId,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  factory VideoBackendState.uninitialized() => const VideoBackendState();

  factory VideoBackendState.erroneous(final String error) =>
      VideoBackendState(hasError: true, error: error);
}

abstract class VideoBackend extends ValueNotifier<VideoBackendState> {
  VideoBackend() : super(VideoBackendState.uninitialized());

  Future<void> initialize(
    Uri link, {
    Map<String, String> headers,
    Duration start,
    Set<String>? preferredLanguage,
  });
  Widget buildVideoWidget();

  Future<void> seekTo(Duration zero);
  Future<void> play();
  Future<void> pause();
  Future<void> setVolume(double volume);
  Future<void> setPlaybackSpeed(double rate);
  Future<void> setAudioTrack(String? id);
  Future<void> setVideoTrack(String? id);
  Future<void> setEquilizer(List<double> bands);
  Future<void> frameStepForward();
  Future<void> frameStepBackward();

  static VideoBackend create() {
    return MediaKitVideoBackend();
  }
}
