import 'package:flutter_test/flutter_test.dart';
import 'package:strumok/content/video/subtitles/subtitle_track.dart';

Duration _s(num seconds) => Duration(milliseconds: (seconds * 1000).round());

SubtitleCue _cue(num start, num end, String text) =>
    SubtitleCue(start: _s(start), end: _s(end), text: text);

List<String> _textsAt(SubtitleTrack track, num seconds) =>
    track.cuesAt(_s(seconds)).map((c) => c.text).toList();

void main() {
  group('SubtitleTrack.cuesAt', () {
    final track = SubtitleTrack([
      _cue(10, 12, 'C'),
      _cue(1, 3, 'A'),
      _cue(4, 6, 'B'),
      _cue(5, 7, 'B2'),
    ]);

    test('sorts cues by start', () {
      expect(track.cues.map((c) => c.text), ['A', 'B', 'B2', 'C']);
    });

    test('returns nothing before, between and after cues', () {
      expect(_textsAt(track, 0), isEmpty);
      expect(_textsAt(track, 3.5), isEmpty);
      expect(_textsAt(track, 13), isEmpty);
    });

    test('treats start as inclusive and end as exclusive', () {
      expect(_textsAt(track, 1), ['A']);
      expect(_textsAt(track, 2.999), ['A']);
      expect(_textsAt(track, 3), isEmpty);
    });

    test('returns all overlapping cues in start order', () {
      expect(_textsAt(track, 5.5), ['B', 'B2']);
      expect(_textsAt(track, 6), ['B2']);
    });

    test('finds long cues that started much earlier', () {
      final withLongCue = SubtitleTrack([
        _cue(0, 100, 'Long'),
        for (var i = 1; i < 50; i++) _cue(i * 2, i * 2 + 1, 'S$i'),
      ]);

      expect(_textsAt(withLongCue, 50.5), ['Long', 'S25']);
      expect(_textsAt(withLongCue, 99.5), ['Long']);
    });

    test('handles an empty track', () {
      final empty = SubtitleTrack(const []);
      expect(empty.isEmpty, isTrue);
      expect(empty.cuesAt(_s(1)), isEmpty);
    });

    test('returns identical cue instances across calls', () {
      expect(track.cuesAt(_s(5.5)), track.cuesAt(_s(5.6)));
    });
  });
}
