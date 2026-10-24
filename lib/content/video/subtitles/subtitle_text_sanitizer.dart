/// Cleans raw subtitle cue text (SRT/WebVTT, often scraped from HTML) into
/// plain text suitable for rendering.
///
/// Most cues are plain text, so every regex pass is gated behind a cheap
/// single-character check and skipped when it cannot match.
library;

final _htmlLineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);
final _voiceTag = RegExp(r'<v(?:\.[^\s.>]+)*\s+([^>]+)>', caseSensitive: false);
final _rubyAnnotation = RegExp(
  r'<(rt|rp)(?:[\s.][^>]*)?>.*?</\1\s*>',
  caseSensitive: false,
  dotAll: true,
);
// Only formatting tags known to appear in subtitles are removed, so text like
// "<3" or "a < b > c" survives. Voice tags with a name are handled by
// [_voiceTag] first; this strips the leftover "<v>" and "</v>".
final _knownTag = RegExp(
  r'</?(?:i|b|u|s|v|em|strong|small|big|sub|sup|font|span|p|div|c|lang|'
  r'ruby|rt|rp|class)(?:[\s.][^>]*)?/?>',
  caseSensitive: false,
);
final _vttTimestampTag = RegExp(r'<(?:\d+:)?\d{1,2}:\d{1,2}[.,]\d{1,3}>');
final _unicodeEscapes = RegExp(r'(?:\\u[0-9a-fA-F]{4})+');
// Group 1: hex numeric, group 2: decimal numeric, group 3: named entity.
final _entity = RegExp(
  r'&(?:#(?:[xX]([0-9a-fA-F]{1,6})|(\d{1,7}))|([a-zA-Z][a-zA-Z0-9]{1,9}));',
);

const _namedEntities = <String, String>{
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': '\u00A0',
  'shy': '\u00AD',
  'lrm': '\u200E',
  'rlm': '\u200F',
  'zwj': '\u200D',
  'zwnj': '\u200C',
  'hellip': '…',
  'mdash': '—',
  'ndash': '–',
  'minus': '−',
  'laquo': '«',
  'raquo': '»',
  'lsquo': '‘',
  'rsquo': '’',
  'sbquo': '‚',
  'ldquo': '“',
  'rdquo': '”',
  'bdquo': '„',
  'bull': '•',
  'middot': '·',
  'deg': '°',
  'copy': '©',
  'reg': '®',
  'trade': '™',
  'euro': '€',
  'times': '×',
  'iexcl': '¡',
  'iquest': '¿',
  'sect': '§',
  'para': '¶',
  'numero': '№',
};

const _tab = 0x09;
const _lf = 0x0A;
const _cr = 0x0D;
const _space = 0x20;

String sanitizeCueText(String raw) {
  var text = raw;

  // Second pass handles double-escaped markup like "&lt;i&gt;Hi&lt;/i&gt;";
  // it only runs when the first pass actually decoded something.
  for (var pass = 0; pass < 2; pass++) {
    if (text.contains('<')) {
      text = text
          .replaceAll(_htmlLineBreak, '\n')
          .replaceAll(_rubyAnnotation, '')
          // Preserves WebVTT voice annotations as plain-text speaker labels.
          .replaceAllMapped(_voiceTag, (match) {
            final name = match[1]!.trim();
            return name.isEmpty ? '' : ' $name: ';
          })
          .replaceAll(_knownTag, '')
          .replaceAll(_vttTimestampTag, '');
    }

    final decoded = decodeHtmlEntities(text);
    if (identical(decoded, text)) break;
    text = decoded;
  }

  if (text.contains(r'\u')) {
    text = text.replaceAllMapped(_unicodeEscapes, _decodeUnicodeEscapes);
  }

  return _normalizeWhitespace(text);
}

/// Decodes HTML entities in [text]. Returns the same instance when nothing
/// was decoded, so callers can detect a no-op with [identical].
String decodeHtmlEntities(String text) {
  if (!text.contains('&')) return text;

  var changed = false;
  final decoded = text.replaceAllMapped(_entity, (m) {
    final hex = m[1];
    final decimal = m[2];
    final name = m[3];

    final String? result;
    if (name != null) {
      result = _namedEntities[name] ?? _namedEntities[name.toLowerCase()];
    } else {
      final codePoint = hex != null
          ? int.parse(hex, radix: 16)
          : int.parse(decimal!);
      result = _codePointToString(codePoint);
    }

    if (result == null) return m[0]!;
    changed = true;
    return result;
  });

  return changed ? decoded : text;
}

// Escapes are decoded as UTF-16 code units so surrogate pairs like
// "\uD83D\uDE00" combine into a single character.
String _decodeUnicodeEscapes(Match match) {
  final escapes = match[0]!;
  final codeUnits = <int>[
    for (var i = 0; i < escapes.length; i += 6)
      int.parse(escapes.substring(i + 2, i + 6), radix: 16),
  ];
  return String.fromCharCodes(codeUnits);
}

String _codePointToString(int codePoint) {
  final isValid =
      codePoint > 0 &&
      codePoint <= 0x10FFFF &&
      (codePoint < 0xD800 || codePoint > 0xDFFF);
  return String.fromCharCode(isValid ? codePoint : 0xFFFD);
}

/// Single pass that collapses runs of spaces/tabs into one space, trims each
/// line (including Unicode whitespace such as NBSP), drops empty lines and
/// removes control characters.
String _normalizeWhitespace(String text) {
  final out = StringBuffer();
  final line = StringBuffer();
  var pendingSpace = false;

  void flushLine() {
    final trimmed = line.toString().trim();
    if (trimmed.isNotEmpty) {
      if (out.isNotEmpty) out.writeCharCode(_lf);
      out.write(trimmed);
    }
    line.clear();
    pendingSpace = false;
  }

  for (final unit in text.codeUnits) {
    if (unit == _lf) {
      flushLine();
    } else if (unit == _space || unit == _tab || unit == _cr) {
      pendingSpace = true;
    } else if (!_isControlChar(unit)) {
      if (pendingSpace) {
        line.writeCharCode(_space);
        pendingSpace = false;
      }
      line.writeCharCode(unit);
    }
  }
  flushLine();

  // Characters are only ever dropped, so equal length means nothing changed.
  return out.length == text.length ? text : out.toString();
}

bool _isControlChar(int unit) =>
    unit <= 0x08 ||
    unit == 0x0B ||
    unit == 0x0C ||
    (unit >= 0x0E && unit <= 0x1F) ||
    unit == 0x7F ||
    unit == 0xFEFF;
