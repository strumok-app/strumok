/// Cleans raw subtitle cue text (SRT/WebVTT, often converted from ASS or
/// scraped from HTML) into plain text suitable for rendering.
library;

final _assOverrideBlock = RegExp(r'\{\\[^}]*\}');
final _assLineBreak = RegExp(r'\\[Nn]');
final _htmlLineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);
final _rubyAnnotation = RegExp(
  r'<(rt|rp)(?:[\s.][^>]*)?>.*?</\1\s*>',
  caseSensitive: false,
  dotAll: true,
);
// Only formatting tags known to appear in subtitles are removed, so text like
// "<3" or "a < b > c" survives.
final _knownTag = RegExp(
  r'</?(?:i|b|u|s|em|strong|small|big|sub|sup|font|span|p|div|c|v|lang|'
  r'ruby|rt|rp|class)(?:[\s.][^>]*)?/?>',
  caseSensitive: false,
);
final _vttTimestampTag = RegExp(r'<(?:\d+:)?\d{1,2}:\d{1,2}[.,]\d{1,3}>');
final _unicodeEscapes = RegExp(r'(?:\\u[0-9a-fA-F]{4})+');
final _numericEntity = RegExp(r'&#(?:[xX]([0-9a-fA-F]{1,6})|(\d{1,7}));');
final _namedEntity = RegExp(r'&([a-zA-Z][a-zA-Z0-9]{1,9});');
final _controlChars = RegExp(
  r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F\uFEFF]',
);
final _horizontalSpaces = RegExp(r'[ \t]+');

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

String sanitizeCueText(String raw) {
  var text = raw
      .replaceAll(_assOverrideBlock, '')
      .replaceAll(_assLineBreak, '\n')
      .replaceAll(r'\h', '\u00A0')
      .replaceAll(_htmlLineBreak, '\n');

  // Second pass handles double-escaped markup like "&lt;i&gt;Hi&lt;/i&gt;".
  for (var pass = 0; pass < 2; pass++) {
    text = text
        .replaceAll(_rubyAnnotation, '')
        .replaceAll(_knownTag, '')
        .replaceAll(_vttTimestampTag, '');
    text = decodeHtmlEntities(text);
  }

  text = text
      .replaceAllMapped(_unicodeEscapes, _decodeUnicodeEscapes)
      .replaceAll(_controlChars, '');

  return text
      .split('\n')
      .map((line) => line.replaceAll(_horizontalSpaces, ' ').trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
}

String decodeHtmlEntities(String text) {
  if (!text.contains('&')) return text;

  return text
      .replaceAllMapped(_numericEntity, (m) {
        final hex = m[1];
        final codePoint = hex != null
            ? int.parse(hex, radix: 16)
            : int.parse(m[2]!);
        return _codePointToString(codePoint);
      })
      .replaceAllMapped(_namedEntity, (m) {
        final name = m[1]!;
        return _namedEntities[name] ??
            _namedEntities[name.toLowerCase()] ??
            m[0]!;
      });
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
