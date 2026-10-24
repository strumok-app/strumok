import 'package:flutter_test/flutter_test.dart';
import 'package:strumok/content/video/subtitles/subtitle_parser.dart';

Duration _ms(int ms) => Duration(milliseconds: ms);

void main() {
  group('parseSubtitles SRT', () {
    test('parses basic cues', () {
      final track = parseSubtitles(
        '1\n00:00:01,000 --> 00:00:02,500\nHello\nworld\n\n'
        '2\n00:00:03,000 --> 00:00:04,000\n<i>Bye</i>\n',
      );

      expect(track.cues, hasLength(2));
      expect(track.cues[0].start, _ms(1000));
      expect(track.cues[0].end, _ms(2500));
      expect(track.cues[0].text, 'Hello\nworld');
      expect(track.cues[1].text, 'Bye');
    });

    test('parses short millisecond fractions as fractions of a second', () {
      final track = parseSubtitles(
        '1\n00:00:07,5 --> 00:00:08,25\nA\n\n'
        '2\n00:00:09.1234 --> 00:00:10\nB\n',
      );

      expect(track.cues[0].start, _ms(7500));
      expect(track.cues[0].end, _ms(8250));
      expect(track.cues[1].start, _ms(9123));
      expect(track.cues[1].end, _ms(10000));
    });

    test('accepts CRLF, CR, BOM and missing trailing newline', () {
      final crlf = parseSubtitles(
        '\uFEFF1\r\n00:00:01,000 --> 00:00:02,000\r\nA\r\n\r\n'
        '2\r\n00:00:03,000 --> 00:00:04,000\r\nB',
      );
      final cr = parseSubtitles('1\r00:00:01,000 --> 00:00:02,000\rA\r');

      expect(crlf.cues.map((c) => c.text), ['A', 'B']);
      expect(cr.cues.single.text, 'A');
    });

    test('handles missing cue numbers and missing blank lines', () {
      final track = parseSubtitles(
        '00:00:01,000 --> 00:00:02,000\nA\n'
        '2\n00:00:03,000 --> 00:00:04,000\nB\n'
        '00:00:05,000 --> 00:00:06,000\nC\n',
      );

      expect(track.cues.map((c) => c.text), ['A', 'B', 'C']);
    });

    test('keeps numeric dialogue lines', () {
      final track = parseSubtitles(
        '1\n00:00:01,000 --> 00:00:02,000\nHow many?\n42\n',
      );

      expect(track.cues.single.text, 'How many?\n42');
    });

    test('accepts timestamps with extra spaces and hour overflow', () {
      final track = parseSubtitles(
        '1\n  100:00:01,000-->100:00:02,000  X1:10 X2:20\nLong\n',
      );

      expect(track.cues.single.start, const Duration(hours: 100, seconds: 1));
      expect(track.cues.single.alignTop, isFalse);
    });

    test('skips cues with empty text or invalid timing', () {
      final track = parseSubtitles(
        '1\n00:00:01,000 --> 00:00:02,000\n<i> </i>\n\n'
        '2\n00:00:05,000 --> 00:00:04,000\nBackwards\n\n'
        '3\n00:00:06,000 --> 00:00:07,000\nOK\n',
      );

      expect(track.cues.single.text, 'OK');
    });

    test('detects ASS top alignment overrides', () {
      final track = parseSubtitles(
        '1\n00:00:01,000 --> 00:00:02,000\n{\\an8}Sign\n\n'
        '2\n00:00:01,000 --> 00:00:02,000\n{\\i1\\an2}Bottom\n\n'
        '3\n00:00:01,000 --> 00:00:02,000\n{\\a6}Legacy top\n',
      );

      expect(track.cues.map((c) => (c.text, c.alignTop)), [
        ('Sign', true),
        ('Bottom', false),
        ('Legacy top', true),
      ]);
    });
  });

  group('parseSubtitles WebVTT', () {
    test('uses cue text, not cue settings', () {
      final track = parseSubtitles(
        'WEBVTT\n\n'
        '00:00:01.000 --> 00:00:02.000 align:start position:10%\n'
        'Settings cue\n',
      );

      expect(track.cues.single.text, 'Settings cue');
      expect(track.cues.single.alignTop, isFalse);
    });

    test('detects top line settings', () {
      final track = parseSubtitles(
        'WEBVTT\n\n'
        '00:00:01.000 --> 00:00:02.000 line:0\nA\n\n'
        '00:00:01.000 --> 00:00:02.000 line:10%,start\nB\n\n'
        '00:00:01.000 --> 00:00:02.000 line:-1\nC\n\n'
        '00:00:01.000 --> 00:00:02.000 line:90%\nD\n',
      );

      expect(track.cues.map((c) => c.alignTop), [true, true, false, false]);
    });

    test('skips header metadata, NOTE, STYLE and REGION blocks', () {
      final track = parseSubtitles(
        'WEBVTT - Title\nKind: captions\nLanguage: en\n\n'
        'STYLE\n::cue { color: yellow }\n\n'
        'REGION\nid:r1 width:40%\n\n'
        'NOTE this is\na comment\n\n'
        'intro\n00:01.000 --> 00:02.000\n<v Bob>Hi &amp; bye</v>\n\n'
        'NOTE\nanother\n\n'
        '00:03.000 --> 00:04.000\nSecond\n',
      );

      expect(track.cues.map((c) => c.text), ['Hi & bye', 'Second']);
      expect(track.cues.first.start, _ms(1000));
    });

    test('parses cue directly after header without blank line', () {
      final track = parseSubtitles(
        'WEBVTT\n00:00:01.000 --> 00:00:02.000\nA\n',
      );

      expect(track.cues.single.text, 'A');
    });

    test('sorts out-of-order cues', () {
      final track = parseSubtitles(
        'WEBVTT\n\n'
        '00:00:05.000 --> 00:00:06.000\nLater\n\n'
        '00:00:01.000 --> 00:00:02.000\nEarlier\n',
      );

      expect(track.cues.map((c) => c.text), ['Earlier', 'Later']);
    });
  });

  group('parseSubtitles errors', () {
    test('returns empty track for files without displayable cues', () {
      expect(parseSubtitles('').isEmpty, isTrue);
      expect(parseSubtitles('WEBVTT\n\n').isEmpty, isTrue);
      expect(
        parseSubtitles('1\n00:00:01,000 --> 00:00:02,000\n<i></i>\n').isEmpty,
        isTrue,
      );
    });

    test('rejects ASS, TTML and HTML', () {
      expect(
        () => parseSubtitles('[Script Info]\nTitle: x\n'),
        throwsA(isA<SubtitleFormatException>()),
      );
      expect(
        () => parseSubtitles('<?xml version="1.0"?><tt></tt>'),
        throwsA(isA<SubtitleFormatException>()),
      );
      expect(
        () => parseSubtitles('<!DOCTYPE html><html></html>'),
        throwsA(isA<SubtitleFormatException>()),
      );
    });

    test('throws when non-empty content has no cues', () {
      expect(
        () => parseSubtitles('just some text\nwithout timings'),
        throwsA(isA<SubtitleFormatException>()),
      );
    });
  });
}
