import 'package:collection/collection.dart';
// ignore: implementation_imports
import 'package:fvp/src/video_player_mdk.dart';
import 'package:strumok/utils/logger.dart';
import 'package:strumok/utils/text.dart';
import 'package:strumok/video_backend/extension.dart';
import 'package:strumok/video_backend/tracks.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FVPVideoPlayerPlatform extends MdkVideoPlayerPlatform
    implements VideoPlayerPlatformWithTracks {
  static void registerWith() {
    MdkVideoPlayerPlatform.registerVideoPlayerPlatformsWith(
      options: {
        // "fastSeek": true,
        "player": {
          "buffer.range": "0+600000",
          "avsync.audio": "1",
          "demux.buffer.ranges": "10",
        },
      },
    );
    VideoPlayerPlatform.instance = FVPVideoPlayerPlatform();
  }

  @override
  List<AudioTrack> getAudioTracks(int textureId) {
    final mediaInfo = getMediaInfo(textureId);
    if (mediaInfo?.audio == null) {
      return [];
    }

    return mediaInfo!.audio!.mapIndexed((idx, stream) {
      String name = "";

      // Try to get human-readable name from metadata first
      if (stream.metadata['comment'] != null) {
        name = stream.metadata['comment']!;
      } else if (stream.metadata['language'] != null) {
        name = stream.metadata['language']!;
      } else {
        // Fall back to codec information
        name = stream.codec.codec;
        if (stream.codec.channels > 0) {
          name += " ${stream.codec.channels}ch";
        }
        if (stream.codec.sampleRate > 0) {
          name += " ${stream.codec.sampleRate}Hz";
        }
        if (stream.codec.bitRate > 0) {
          name += " ${formatBytes(stream.codec.bitRate)}it/s";
        }
      }

      return AudioTrack(id: idx.toString(), name: "${idx + 1}. $name");
    }).toList();
  }

  @override
  String? getCurrentAudioTrackId(int textureId) {
    final activeTracks = getActiveAudioTracks(textureId);
    return activeTracks?.isNotEmpty == true
        ? activeTracks!.first.toString()
        : null;
  }

  @override
  String? getCurrentVideoTrackId(int textureId) {
    final activeTracks = getActiveVideoTracks(textureId);
    return activeTracks?.isNotEmpty == true
        ? activeTracks!.first.toString()
        : null;
  }

  @override
  List<VideoTrack> getVideoTracks(int textureId) {
    final mediaInfo = getMediaInfo(textureId);
    if (mediaInfo?.video == null) {
      return [];
    }

    return mediaInfo!.video!.mapIndexed((idx, stream) {
      return VideoTrack(
        id: idx.toString(),
        height: stream.codec.height,
        width: stream.codec.width,
        fps: stream.codec.frameRate,
        samplerate: null,
      );
    }).toList();
  }

  @override
  void selectAudioTrack(int textureId, String id) {
    if (int.tryParse(id) case final trackIndex?) {
      setAudioTracks(textureId, [trackIndex]);
    }
  }

  @override
  void selectVideoTrack(int textureId, String id) {
    if (int.tryParse(id) case final trackIndex?) {
      setVideoTracks(textureId, [trackIndex]);
    }
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    final tex = (await super.create(dataSource))!;

    final mediaInfo = getMediaInfo(tex);
    logger.info(mediaInfo);

    if (mediaInfo?.video != null) {
      final videoTracks = mediaInfo!.video!;

      int bestTrackIndex = 0;
      int bestTrackRes = 0;

      for (int i = 0; i < videoTracks.length; i++) {
        final track = videoTracks[i];
        final res = track.codec.width * track.codec.height;

        if (res >= bestTrackRes) {
          bestTrackRes = res;
          bestTrackIndex = i;
        }
      }

      logger.info(
        "Best video track $bestTrackIndex: ${videoTracks[bestTrackIndex]}",
      );

      setVideoTracks(tex, [bestTrackIndex]);
    }

    return tex;
  }
}
