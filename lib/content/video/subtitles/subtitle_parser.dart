import 'package:strumok/content/video/subtitles/subtitle_text_sanitizer.dart';
import 'package:strumok/content/video/subtitles/subtitle_track.dart';

class SubtitleFormatException implements Exception {
  final String message;

  const SubtitleFormatException(this.message);

  @override
  String toString() => 'SubtitleFormatException: $message';
}

// Timestamp: [hours:]minutes:seconds[.,]fraction (fraction optional).
const _timestamp = r'((?:\d+:)?\d{1,2}:\d{1,2}(?:[.,]\d+)?)';
final _timingLine = RegExp('^\\s*$_timestamp\\s*-->\\s*$_timestamp(.*)\$');
final _integerLine = RegExp(r'^\s*\d+\s*$');
final _vttBlockKeyword = RegExp(r'^(?:NOTE|STYLE|REGION)(?:[ \t]|$)');
final _assTopAlignment = RegExp(
  r'\{[^}]*\\(?:an[789]|a(?:5|6|7)(?!\d))[^}]*\}',
);
final _vttLineSetting = RegExp(r'(?:^|\s)line:(-?\d+(?:\.\d+)?)(%?)');

/// Parses SubRip (SRT) or WebVTT [content] into a [SubtitleTrack].
///
/// The parser is lenient: it accepts `.` or `,` as millisecond separator,
/// missing hours, missing cue numbers, missing blank lines between cues and
/// any line ending. Cue text is cleaned with [sanitizeCueText].
SubtitleTrack parseSubtitles(String content) {
  final text = content.startsWith('\uFEFF') ? content.substring(1) : content;
  _rejectUnsupportedFormats(text);

  final lines = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');

  final cues = <SubtitleCue>[];
  final isVtt = lines.first.trimLeft().startsWith('WEBVTT');
  var hasTimings = false;
  var i = isVtt ? _skipBlock(lines, 0) : 0;

  while (i < lines.length) {
    final line = lines[i];

    if (_vttBlockKeyword.hasMatch(line)) {
      i = _skipBlock(lines, i);
      continue;
    }

    final timing = _timingLine.firstMatch(line);
    if (timing == null) {
      // Cue number, WebVTT cue identifier, blank line or garbage.
      i++;
      continue;
    }

    hasTimings = true;
    i++;
    final textLines = <String>[];
    while (i < lines.length && lines[i].trim().isNotEmpty) {
      if (_timingLine.hasMatch(lines[i])) {
        // Missing blank line before the next cue: drop its cue number.
        if (textLines.isNotEmpty && _integerLine.hasMatch(textLines.last)) {
          textLines.removeLast();
        }
        break;
      }
      textLines.add(lines[i]);
      i++;
    }

    final cue = _buildCue(timing, textLines.join('\n'));
    if (cue != null) {
      cues.add(cue);
    }
  }

  if (!isVtt && !hasTimings && text.trim().isNotEmpty) {
    throw const SubtitleFormatException('No subtitle cues found');
  }

  return SubtitleTrack(cues);
}

void _rejectUnsupportedFormats(String text) {
  final head = text
      .substring(0, text.length < 1024 ? text.length : 1024)
      .trimLeft();
  final lowerHead = head.toLowerCase();

  if (head.startsWith('[Script Info]') ||
      head.contains('\n[V4+ Styles]') ||
      head.contains('\n[V4 Styles]')) {
    throw const SubtitleFormatException('ASS/SSA subtitles are not supported');
  }
  if (lowerHead.startsWith('<?xml') || lowerHead.startsWith('<tt')) {
    throw const SubtitleFormatException('TTML subtitles are not supported');
  }
  if (lowerHead.startsWith('<!doctype html') || lowerHead.startsWith('<html')) {
    throw const SubtitleFormatException(
      'Expected subtitles but received an HTML page',
    );
  }
}

/// Returns the index of the first line after the block starting at [start].
/// Stops early at a timing line in case the blank separator line is missing.
int _skipBlock(List<String> lines, int start) {
  var i = start + 1;
  while (i < lines.length &&
      lines[i].trim().isNotEmpty &&
      !_timingLine.hasMatch(lines[i])) {
    i++;
  }
  return i;
}

SubtitleCue? _buildCue(RegExpMatch timing, String rawText) {
  final start = _parseTimestamp(timing[1]!);
  final end = _parseTimestamp(timing[2]!);
  if (start == null || end == null || end <= start) {
    return null;
  }

  final text = sanitizeCueText(rawText);
  if (text.isEmpty) {
    return null;
  }

  return SubtitleCue(
    start: start,
    end: end,
    text: text,
    alignTop:
        _assTopAlignment.hasMatch(rawText) || _isVttTopLine(timing[3] ?? ''),
  );
}

Duration? _parseTimestamp(String value) {
  final separator = value.indexOf(RegExp('[.,]'));
  final clock = separator == -1 ? value : value.substring(0, separator);
  final fraction = separator == -1 ? '' : value.substring(separator + 1);

  final parts = clock.split(':').map(int.tryParse).toList();
  if (parts.any((p) => p == null)) {
    return null;
  }

  final hours = parts.length == 3 ? parts[0]! : 0;
  final minutes = parts[parts.length - 2]!;
  final seconds = parts.last!;

  // Fraction of a second: "5" → 500 ms, "25" → 250 ms, "1234" → 123 ms.
  final milliseconds = fraction.isEmpty
      ? 0
      : int.parse(fraction.padRight(3, '0').substring(0, 3));

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

/// WebVTT `line:` setting: percentage from the top, or a line number where
/// non-negative values count from the top and negative ones from the bottom.
bool _isVttTopLine(String settings) {
  final match = _vttLineSetting.firstMatch(settings);
  if (match == null) {
    return false;
  }

  final value = double.tryParse(match[1]!);
  if (value == null) {
    return false;
  }

  final isPercent = match[2] == '%';
  return isPercent ? value < 50 : value >= 0 && value <= 4;
}
