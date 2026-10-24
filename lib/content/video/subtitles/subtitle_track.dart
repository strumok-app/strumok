class SubtitleCue {
  final Duration start;
  final Duration end;
  final String text;

  /// Cue requested top placement (ASS `{\an8}` or WebVTT `line:0`), typically
  /// forced subtitles for on-screen signs.
  final bool alignTop;

  const SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
    this.alignTop = false,
  });

  bool isActiveAt(Duration time) => time >= start && time < end;

  @override
  String toString() => 'SubtitleCue($start --> $end, top: $alignTop, "$text")';
}

/// Immutable, start-sorted set of cues with fast lookup by playback time.
class SubtitleTrack {
  final List<SubtitleCue> cues;
  final Duration _longestCue;

  factory SubtitleTrack(Iterable<SubtitleCue> cues) {
    final sorted = cues.toList()..sort((a, b) => a.start.compareTo(b.start));
    var longest = Duration.zero;
    for (final cue in sorted) {
      final length = cue.end - cue.start;
      if (length > longest) longest = length;
    }
    return SubtitleTrack._(List.unmodifiable(sorted), longest);
  }

  const SubtitleTrack._(this.cues, this._longestCue);

  bool get isEmpty => cues.isEmpty;

  /// Cues active at [time], in start order. Overlapping cues are all returned.
  List<SubtitleCue> cuesAt(Duration time) {
    // First index whose start is after [time].
    var low = 0;
    var high = cues.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (cues[mid].start <= time) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }

    // Only cues starting within the longest cue duration can still be active.
    final earliestStart = time - _longestCue;
    final result = <SubtitleCue>[];
    for (var i = low - 1; i >= 0 && cues[i].start >= earliestStart; i--) {
      if (cues[i].isActiveAt(time)) {
        result.add(cues[i]);
      }
    }

    return result.reversed.toList(growable: false);
  }
}
