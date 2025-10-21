// import 'dart:io';

// import 'package:collection/collection.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// // ignore: implementation_imports
// import 'package:fvp/src/video_player_mdk.dart';
// import 'package:http/http.dart' as http;
// import 'package:logging/logging.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:strumok/utils/logger.dart';
// import 'package:strumok/utils/text.dart';
// import 'package:strumok/video_backend/extension.dart';
// import 'package:strumok/video_backend/tracks.dart';
// import 'package:video_player_platform_interface/video_player_platform_interface.dart';

// import 'package:fvp/mdk.dart' as mdk;
// import 'package:fvp/src/fvp_platform_interface.dart';
// import 'package:fvp/src/extensions.dart';

// class FVPVideoPlayerPlatform extends VideoPlayerPlatform
//     implements VideoPlayerPlatformWithTracks {
//   static final _players = <int, MdkVideoPlayer>{};
//   static Map<String, Object>? _globalOpts;
//   static Map<String, String>? _playerOpts;
//   static int? _maxWidth;
//   static int? _maxHeight;
//   static bool? _fitMaxSize;
//   static bool? _tunnel;
//   static String? _subtitleFontFile;
//   static int _lowLatency = 0;
//   static int _seekFlags = mdk.SeekFlag.fromStart | mdk.SeekFlag.inCache;
//   static List<String>? _decoders;
//   static final _mdkLog = Logger("MDK");

//   /*
//   Registers this class as the default instance of [VideoPlayerPlatform].

//   [options] can be
//   "video.decoders": a list of decoder names. supported decoders: https://github.com/wang-bin/mdk-sdk/wiki/Decoders
//   "maxWidth", "maxHeight": texture max size. if not set, video frame size is used. a small value can reduce memory cost, but may result in lower image quality.
//  */
//   static void registerWith() {
//     final dynamic options = {
//       // "fastSeek": true,
//       // "player": {
//       // "buffer.range": "0+600000",
//       // "avsync.audio": "1",
//       // "demux.buffer.ranges": "1",
//       // },
//     };

//     logger.fine('registerVideoPlayerPlatformsWith: $options');

//     if ((options['fastSeek'] ?? false) as bool) {
//       _seekFlags |= mdk.SeekFlag.keyFrame;
//     }
//     _lowLatency = (options['lowLatency'] ?? 0) as int;
//     _maxWidth = options["maxWidth"];
//     _maxHeight = options["maxHeight"];
//     _fitMaxSize = options["fitMaxSize"];
//     _tunnel = options["tunnel"];
//     _playerOpts = options['player'];
//     _globalOpts = options['global'];
//     _decoders = options['video.decoders'];
//     _subtitleFontFile = options['subtitleFontFile'];

//     if (_decoders == null) {
//       final vdLinux = ['VAAPI', 'CUDA', 'VDPAU', 'hap', 'FFmpeg', 'dav1d'];
//       final vd = {
//         'windows': [
//           'MFT:d3d=11',
//           "D3D11",
//           "DXVA",
//           'CUDA',
//           'hap',
//           'FFmpeg',
//           'dav1d',
//         ],
//         'macos': ['VT', 'hap', 'FFmpeg', 'dav1d'],
//         'ios': ['VT', 'FFmpeg', 'dav1d'],
//         'linux': vdLinux,
//         'android': ['AMediaCodec', 'FFmpeg', 'dav1d'],
//       };
//       _decoders = vd[Platform.operatingSystem];
//     }

//     // delay: ensure log handler is set in main(), blank window if run with debugger.
//     // registerWith() can be invoked by dart_plugin_registrant.dart before main. when debugging, won't enter main if posting message from native to dart(new native log message) before main?
//     Future.delayed(const Duration(milliseconds: 0), () {
//       _setupMdk();
//     });

//     VideoPlayerPlatform.instance = FVPVideoPlayerPlatform();
//   }

//   static void _setupMdk() {
//     mdk.setLogHandler((level, msg) {
//       if (msg.endsWith('\n')) {
//         msg = msg.substring(0, msg.length - 1);
//       }
//       switch (level) {
//         case mdk.LogLevel.error:
//           _mdkLog.severe(msg);
//         case mdk.LogLevel.warning:
//           _mdkLog.warning(msg);
//         case mdk.LogLevel.info:
//           _mdkLog.info(msg);
//         case mdk.LogLevel.debug:
//         // _mdkLog.fine(msg);
//         case mdk.LogLevel.all:
//         // _mdkLog.finest(msg);
//         default:
//           return;
//       }
//     });
//     // mdk.setGlobalOptions('plugins', 'mdk-braw');
//     mdk.setGlobalOption("log", "all");
//     mdk.setGlobalOption('d3d11.sync.cpu', 1);
//     if (_subtitleFontFile?.startsWith('http') ?? false) {
//       final fileName = _subtitleFontFile!.split('/').last;
//       getApplicationCacheDirectory().then((dir) {
//         final fontPath = '${dir.path}/$fileName';
//         logger.fine('check font path: $fontPath');
//         if (File(fontPath).existsSync()) {
//           mdk.setGlobalOption('subtitle.fonts.file', fontPath);
//           return;
//         }
//         logger.fine('downloading font file: $_subtitleFontFile');
//         http.get(Uri.parse(_subtitleFontFile!)).then((response) {
//           if (response.statusCode == 200) {
//             logger.fine('save font file: $fontPath');
//             File(fontPath).writeAsBytes(response.bodyBytes).then((_) {
//               mdk.setGlobalOption('subtitle.fonts.file', fontPath);
//             });
//           }
//         });
//       });
//     } else {
//       mdk.setGlobalOption(
//         'subtitle.fonts.file',
//         PlatformEx.assetUri(_subtitleFontFile ?? 'assets/subfont.ttf'),
//       );
//     }
//     _globalOpts?.forEach((key, value) {
//       mdk.setGlobalOption(key, value);
//     });
//   }

//   @override
//   Future<void> init() async {}

//   @override
//   Future<void> dispose(int playerId) async {
//     _players.remove(playerId)?.dispose();
//   }

//   @override
//   Future<int?> create(DataSource dataSource) async {
//     final uri = _toUri(dataSource);
//     final player = MdkVideoPlayer();
//     logger.fine('$hashCode player${player.nativeHandle} create($uri)');

//     //player.setProperty("keep_open", "1");
//     player.setProperty('video.decoder', 'shader_resource=0');
//     player.setProperty('avformat.strict', 'experimental');
//     player.setProperty('avformat.safe', '0');
//     player.setProperty('avio.reconnect', '1');
//     player.setProperty('avio.reconnect_delay_max', '7');
//     player.setProperty('avformat.rtsp_transport', 'tcp');
//     player.setProperty('avformat.extension_picky', '0');
//     player.setProperty('avformat.allowed_segment_extensions', 'ALL');
//     if (dataSource.sourceType != DataSourceType.network) {
//       // for m3u8 local file etc.
//       player.setProperty(
//         'avio.protocol_whitelist',
//         'file,ftp,rtmp,http,https,tls,rtp,tcp,udp,crypto,httpproxy,data,concatf,concat,subfile',
//       );
//     }
//     _playerOpts?.forEach((key, value) {
//       player.setProperty(key, value);
//     });

//     if (_decoders != null) {
//       player.videoDecoders = _decoders!;
//     }
//     if (_lowLatency > 0) {
//       // +nobuffer: the 1st key-frame packet is dropped. -nobuffer: high latency
//       player.setProperty('avformat.fflags', '+nobuffer');
//       player.setProperty('avformat.fpsprobesize', '0');
//       player.setProperty('avformat.analyzeduration', '100000');
//       if (_lowLatency > 1) {
//         player.setBufferRange(min: 0, max: 1000, drop: true);
//       } else {
//         player.setBufferRange(min: 0);
//       }
//     }

//     if (dataSource.httpHeaders.isNotEmpty) {
//       String headers = '';
//       dataSource.httpHeaders.forEach((key, value) {
//         headers += '$key: $value\r\n';
//       });
//       player.setProperty('avio.headers', headers);
//     }
//     player.media = uri;
//     int ret = await player.prepare(); // required!
//     if (ret < 0) {
//       // no throw, handle error in controller.addListener
//       _players[-hashCode] = player;
//       player.streamCtl.addError(
//         PlatformException(
//           code: 'media open error',
//           message: 'invalid or unsupported media',
//         ),
//       );
//       //player.dispose(); // dispose for throw
//       return -hashCode;
//     }

//     final mediaInfo = player.mediaInfo;
//     logger.info(mediaInfo);

//     if (mediaInfo.video != null) {
//       final videoTracks = mediaInfo.video!;

//       int bestTrackIndex = 0;
//       int bestTrackRes = 0;

//       for (int i = 0; i < videoTracks.length; i++) {
//         final track = videoTracks[i];
//         final res = track.codec.width * track.codec.height;

//         if (res >= bestTrackRes) {
//           bestTrackRes = res;
//           bestTrackIndex = i;
//         }
//       }

//       logger.info(
//         "Best video track $bestTrackIndex: ${videoTracks[bestTrackIndex]}",
//       );

//       player.activeVideoTracks = [bestTrackIndex];
//     }

//     // FIXME: pending events will be processed after texture returned, but no events before prepared
//     // FIXME: set tunnel too late
//     final tex = await player.updateTexture(
//       width: _maxWidth,
//       height: _maxHeight,
//       tunnel: _tunnel,
//       fit: _fitMaxSize,
//     );
//     if (tex < 0) {
//       _players[-hashCode] = player;
//       player.streamCtl.addError(
//         PlatformException(
//           code: 'video size error',
//           message: 'invalid or unsupported media with invalid video size',
//         ),
//       );
//       //player.dispose();
//       return -hashCode;
//     }
//     logger.fine('$hashCode player${player.nativeHandle} textureId=$tex');
//     _players[tex] = player;

//     return tex;
//   }

//   @override
//   Future<void> setLooping(int playerId, bool looping) async {
//     final player = _players[playerId];
//     if (player != null) {
//       player.loop = looping ? -1 : 0;
//     }
//   }

//   @override
//   Future<void> play(int playerId) async {
//     _players[playerId]?.state = mdk.PlaybackState.playing;
//   }

//   @override
//   Future<void> pause(int playerId) async {
//     _players[playerId]?.state = mdk.PlaybackState.paused;
//   }

//   @override
//   Future<void> setVolume(int playerId, double volume) async {
//     _players[playerId]?.volume = volume;
//   }

//   @override
//   Future<void> setPlaybackSpeed(int playerId, double speed) async {
//     _players[playerId]?.playbackRate = speed;
//   }

//   @override
//   Future<void> seekTo(int playerId, Duration position) async {
//     print("SEEK POS: $position!!!!!!");
//     return _seekToWithFlags(playerId, position, mdk.SeekFlag(_seekFlags));
//   }

//   @override
//   Future<Duration> getPosition(int playerId) async {
//     final player = _players[playerId];
//     if (player == null) {
//       return Duration.zero;
//     }
//     final pos = player.position;
//     final bufLen = player.buffered();
//     final ranges = player.bufferedTimeRanges();
//     player.streamCtl.add(
//       VideoEvent(
//         eventType: VideoEventType.bufferingUpdate,
//         buffered:
//             ranges +
//             [
//               DurationRange(
//                 Duration(milliseconds: pos),
//                 Duration(milliseconds: pos + bufLen),
//               ),
//             ],
//       ),
//     );
//     return Duration(milliseconds: pos);
//   }

//   @override
//   Stream<VideoEvent> videoEventsFor(int playerId) {
//     final player = _players[playerId];
//     if (player != null) {
//       return player.streamCtl.stream;
//     }
//     throw Exception('No Stream<VideoEvent> for textureId: $playerId.');
//   }

//   @override
//   Widget buildView(int playerId) {
//     return Texture(textureId: playerId);
//   }

//   @override
//   Future<void> setMixWithOthers(bool mixWithOthers) async {
//     FvpPlatform.instance.setMixWithOthers(mixWithOthers);
//   }

//   // more apis for fvp controller
//   bool isLive(int playerId) {
//     return _players[playerId]?.isLive ?? false;
//   }

//   mdk.MediaInfo? getMediaInfo(int playerId) {
//     return _players[playerId]?.mediaInfo;
//   }

//   void setProperty(int playerId, String name, String value) {
//     _players[playerId]?.setProperty(name, value);
//   }

//   void setAudioDecoders(int playerId, List<String> value) {
//     _players[playerId]?.audioDecoders = value;
//   }

//   void setVideoDecoders(int playerId, List<String> value) {
//     _players[playerId]?.videoDecoders = value;
//   }

//   void record(int playerId, {String? to, String? format}) {
//     _players[playerId]?.record(to: to, format: format);
//   }

//   Future<Uint8List?> snapshot(int playerId, {int? width, int? height}) async {
//     Uint8List? data;
//     final player = _players[playerId];
//     if (player == null) {
//       return data;
//     }
//     return _players[playerId]?.snapshot(width: width, height: height);
//   }

//   void setRange(int textureId, {required int from, int to = -1}) {
//     _players[textureId]?.setRange(from: from, to: to);
//   }

//   void setBufferRange(
//     int textureId, {
//     int min = -1,
//     int max = -1,
//     bool drop = false,
//   }) {
//     _players[textureId]?.setBufferRange(min: min, max: max, drop: drop);
//   }

//   Future<void> fastSeekTo(int playerId, Duration position) async {
//     return _seekToWithFlags(
//       playerId,
//       position,
//       mdk.SeekFlag(_seekFlags | mdk.SeekFlag.keyFrame),
//     );
//   }

//   Future<void> step(int playerId, int frames) async {
//     final player = _players[playerId];
//     if (player == null) {
//       return;
//     }
//     player.seek(
//       position: frames,
//       flags: const mdk.SeekFlag(mdk.SeekFlag.frame | mdk.SeekFlag.fromNow),
//     );
//   }

//   void setBrightness(int playerId, double value) {
//     _players[playerId]?.setVideoEffect(mdk.VideoEffect.brightness, [value]);
//   }

//   void setContrast(int playerId, double value) {
//     _players[playerId]?.setVideoEffect(mdk.VideoEffect.contrast, [value]);
//   }

//   void setHue(int playerId, double value) {
//     _players[playerId]?.setVideoEffect(mdk.VideoEffect.hue, [value]);
//   }

//   void setSaturation(int playerId, double value) {
//     _players[playerId]?.setVideoEffect(mdk.VideoEffect.saturation, [value]);
//   }

//   void setProgram(int playerId, int programId) {
//     _players[playerId]?.setActiveTracks(mdk.MediaType.unknown, [programId]);
//   }

//   // embedded tracks, can be main data source from create(), or external media source via setExternalAudio
//   void setAudioTracks(int playerId, List<int> value) {
//     _players[playerId]?.activeAudioTracks = value;
//   }

//   List<int>? getActiveAudioTracks(int playerId) {
//     return _players[playerId]?.activeAudioTracks;
//   }

//   void setVideoTracks(int playerId, List<int> value) {
//     _players[playerId]?.activeVideoTracks = value;
//   }

//   List<int>? getActiveVideoTracks(int playerId) {
//     return _players[playerId]?.activeVideoTracks;
//   }

//   void setSubtitleTracks(int playerId, List<int> value) {
//     _players[playerId]?.activeSubtitleTracks = value;
//   }

//   List<int>? getActiveSubtitleTracks(int playerId) {
//     return _players[playerId]?.activeSubtitleTracks;
//   }

//   // external track. can select external tracks via setAudioTracks()
//   void setExternalAudio(int playerId, String uri) {
//     _players[playerId]?.setMedia(uri, mdk.MediaType.audio);
//   }

//   void setExternalVideo(int playerId, String uri) {
//     _players[playerId]?.setMedia(uri, mdk.MediaType.video);
//   }

//   void setExternalSubtitle(int playerId, String uri) {
//     _players[playerId]?.setMedia(uri, mdk.MediaType.subtitle);
//   }

//   Future<void> _seekToWithFlags(
//     int playerId,
//     Duration position,
//     mdk.SeekFlag flags,
//   ) async {
//     final player = _players[playerId];
//     if (player == null) {
//       return;
//     }
//     if (player.isLive) {
//       final bufMax = player.buffered();
//       final pos = player.position;
//       if (position.inMilliseconds <= pos ||
//           position.inMilliseconds > pos + bufMax) {
//         logger.fine(
//           '_seekToWithFlags: $position out of live stream buffered range [$pos, ${pos + bufMax}]',
//         );
//         return;
//       }
//     }
//     return player
//         .seek(position: position.inMilliseconds, flags: flags)
//         .then((_) => null);
//   }

//   String _toUri(DataSource dataSource) {
//     switch (dataSource.sourceType) {
//       case DataSourceType.asset:
//         return PlatformEx.assetUri(
//           dataSource.asset!,
//           package: dataSource.package,
//         );
//       case DataSourceType.network:
//         return dataSource.uri!;
//       case DataSourceType.file:
//         return Uri.decodeComponent(dataSource.uri!);
//       case DataSourceType.contentUri:
//         return dataSource.uri!;
//     }
//   }

//   @override
//   List<AudioTrack> getAudioTracks(int playerId) {
//     final mediaInfo = getMediaInfo(playerId);
//     if (mediaInfo?.audio == null) {
//       return [];
//     }

//     return mediaInfo!.audio!.mapIndexed((idx, stream) {
//       String name = "";

//       // Try to get human-readable name from metadata first
//       if (stream.metadata['comment'] != null) {
//         name = stream.metadata['comment']!;
//       } else if (stream.metadata['language'] != null) {
//         name = stream.metadata['language']!;
//       } else {
//         // Fall back to codec information
//         name = stream.codec.codec;
//         if (stream.codec.channels > 0) {
//           name += " ${stream.codec.channels}ch";
//         }
//         if (stream.codec.sampleRate > 0) {
//           name += " ${stream.codec.sampleRate}Hz";
//         }
//         if (stream.codec.bitRate > 0) {
//           name += " ${formatBytes(stream.codec.bitRate)}it/s";
//         }
//       }

//       return AudioTrack(id: idx.toString(), name: "${idx + 1}. $name");
//     }).toList();
//   }

//   @override
//   String? getCurrentAudioTrackId(int playerId) {
//     final activeTracks = getActiveAudioTracks(playerId);
//     return activeTracks?.isNotEmpty == true
//         ? activeTracks!.first.toString()
//         : null;
//   }

//   @override
//   String? getCurrentVideoTrackId(int playerId) {
//     final activeTracks = getActiveVideoTracks(playerId);
//     return activeTracks?.isNotEmpty == true
//         ? activeTracks!.first.toString()
//         : null;
//   }

//   @override
//   List<VideoTrack> getVideoTracks(int playerId) {
//     final mediaInfo = getMediaInfo(playerId);
//     if (mediaInfo?.video == null) {
//       return [];
//     }

//     return mediaInfo!.video!.mapIndexed((idx, stream) {
//       return VideoTrack(
//         id: idx.toString(),
//         height: stream.codec.height,
//         width: stream.codec.width,
//         fps: stream.codec.frameRate,
//         samplerate: null,
//       );
//     }).toList();
//   }

//   @override
//   void selectAudioTrack(int playerId, String id) {
//     if (int.tryParse(id) case final trackIndex?) {
//       setAudioTracks(playerId, [trackIndex]);
//     }
//   }

//   @override
//   void selectVideoTrack(int playerId, String id) {
//     if (int.tryParse(id) case final trackIndex?) {
//       setVideoTracks(playerId, [trackIndex]);
//     }
//   }
// }
