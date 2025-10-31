import 'package:strumok/video_backend/tracks.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

extension PlayerVideoControlerExt on VideoPlayerController {
  int get _textureId {
    final d = this as dynamic;
    return d.playerId as int;
  }

  VideoPlayerPlatformExtend? get _extendPlatform {
    if (VideoPlayerPlatform.instance is VideoPlayerPlatformExtend) {
      return VideoPlayerPlatform.instance as VideoPlayerPlatformExtend;
    }

    return null;
  }

  List<VideoTrack> get videoTracks =>
      _extendPlatform?.getAllVideoTracks(_textureId) ?? [];
  List<AudioTrack> get audioTracks =>
      _extendPlatform?.getAllAudioTracks(_textureId) ?? [];

  set currentAudioTrackId(String? id) {
    if (id != null) _extendPlatform?.setCurrentAudioTrack(_textureId, id);
  }

  set currentVideoTrackId(String? id) {
    if (id != null) _extendPlatform?.setCurrentVideoTrack(_textureId, id);
  }

  String? get currentVideoTrackId =>
      _extendPlatform?.getCurrentVideoTrackId(_textureId);

  String? get currentAudioTrackId =>
      _extendPlatform?.getCurrentAudioTrackId(_textureId);

  set equilizer(List<double> bands) =>
      _extendPlatform?.setEquilizer(_textureId, bands);
}

abstract interface class VideoPlayerPlatformExtend {
  List<VideoTrack> getAllVideoTracks(int textureId);
  List<AudioTrack> getAllAudioTracks(int textureId);
  void setCurrentAudioTrack(int textureId, String id) {}
  void setCurrentVideoTrack(int textureId, String id) {}
  String? getCurrentVideoTrackId(int textureId);
  String? getCurrentAudioTrackId(int textureId);
  void setEquilizer(int textureId, List<double> bands);
}
