class VideoTrack {
  final String id;
  final int height;
  final int width;
  final double? fps;
  final int? samplerate;

  VideoTrack({
    required this.id,
    required this.height,
    required this.width,
    required this.fps,
    required this.samplerate,
  });

  String get name => width > 0 ? "${width}x$height" : id;
}

class AudioTrack {
  final String id;
  final String name;

  AudioTrack({required this.id, required this.name});
}
