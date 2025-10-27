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
      _extendPlatform?.getVideoTracks(_textureId) ?? [];
  List<AudioTrack> get audioTracks =>
      _extendPlatform?.getAudioTracks(_textureId) ?? [];

  void selectAudioTrack(String id) {
    _extendPlatform?.selectAudioTrack(_textureId, id);
  }

  void selectVideoTrack(String id) {
    _extendPlatform?.selectVideoTrack(_textureId, id);
  }

  String? get currentVideoTrackId =>
      _extendPlatform?.getCurrentVideoTrackId(_textureId);

  String? get currentAudioTrackId =>
      _extendPlatform?.getCurrentAudioTrackId(_textureId);

  set equilizer(List<double> bands) =>
      _extendPlatform?.setEquilizer(_textureId, bands);
}

abstract interface class VideoPlayerPlatformExtend {
  List<VideoTrack> getVideoTracks(int textureId);
  List<AudioTrack> getAudioTracks(int textureId);
  void selectAudioTrack(int textureId, String id) {}
  void selectVideoTrack(int textureId, String id) {}
  String? getCurrentVideoTrackId(int textureId);
  String? getCurrentAudioTrackId(int textureId);
  void setEquilizer(int textureId, List<double> bands);
}
