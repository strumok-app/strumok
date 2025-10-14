import 'package:strumok/video_backend/tracks.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

extension PlayerVideoControlerExt on VideoPlayerController {
  int get _textureId {
    final d = this as dynamic;
    return d.playerId as int;
  }

  VideoPlayerPlatformWithTracks? get _platformTracks {
    if (VideoPlayerPlatform.instance is VideoPlayerPlatformWithTracks) {
      return VideoPlayerPlatform.instance as VideoPlayerPlatformWithTracks;
    }

    return null;
  }

  List<VideoTrack> get videoTracks =>
      _platformTracks?.getVideoTracks(_textureId) ?? [];
  List<AudioTrack> get audioTracks =>
      _platformTracks?.getAudioTracks(_textureId) ?? [];

  void selectAudioTrack(String id) {
    _platformTracks?.selectAudioTrack(_textureId, id);
  }

  void selectVideoTrack(String id) {
    _platformTracks?.selectVideoTrack(_textureId, id);
  }

  String? get currentVideoTrackId =>
      _platformTracks?.getCurrentVideoTrackId(_textureId);

  String? get currentAudioTrackId =>
      _platformTracks?.getCurrentAudioTrackId(_textureId);
}

abstract interface class VideoPlayerPlatformWithTracks {
  List<VideoTrack> getVideoTracks(int textureId);
  List<AudioTrack> getAudioTracks(int textureId);
  void selectAudioTrack(int textureId, String id) {}
  void selectVideoTrack(int textureId, String id) {}
  String? getCurrentVideoTrackId(int textureId);
  String? getCurrentAudioTrackId(int textureId);
}
