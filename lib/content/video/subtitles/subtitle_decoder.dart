import 'dart:convert';

/// Decodes raw subtitle file bytes into a string.
///
/// Order: BOM (UTF-8 / UTF-16 LE/BE) → strict UTF-8 →
/// legacy single-byte fallback (Windows-1251 for Cyrillic-looking
/// content, Windows-1252 otherwise).
String decodeSubtitleBytes(List<int> bytes) {
  if (_startsWith(bytes, const [0xEF, 0xBB, 0xBF])) {
    return utf8.decode(bytes.sublist(3), allowMalformed: true);
  }
  if (_startsWith(bytes, const [0xFF, 0xFE])) {
    return _decodeUtf16(bytes, 2, littleEndian: true);
  }
  if (_startsWith(bytes, const [0xFE, 0xFF])) {
    return _decodeUtf16(bytes, 2, littleEndian: false);
  }

  try {
    return utf8.decode(bytes);
  } on FormatException {
    return _looksLikeCyrillic(bytes)
        ? _decodeSingleByte(bytes, _cp1251High)
        : _decodeCp1252(bytes);
  }
}

bool _startsWith(List<int> bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}

String _decodeUtf16(List<int> bytes, int offset, {required bool littleEndian}) {
  final length = (bytes.length - offset) & ~1;
  final codeUnits = List<int>.filled(length ~/ 2, 0);
  for (var i = 0; i < codeUnits.length; i++) {
    final a = bytes[offset + i * 2];
    final b = bytes[offset + i * 2 + 1];
    codeUnits[i] = littleEndian ? (b << 8) | a : (a << 8) | b;
  }
  return String.fromCharCodes(codeUnits);
}

/// Windows-1251 Cyrillic words are runs of consecutive high bytes, while in
/// Western Windows-1252 text accented letters are mostly isolated between
/// ASCII letters.
bool _looksLikeCyrillic(List<int> bytes) {
  var letters = 0;
  var adjacentPairs = 0;
  var previousIsLetter = false;
  for (final b in bytes) {
    final isLetter = _isCp1251Letter(b);
    if (isLetter) {
      letters++;
      if (previousIsLetter) adjacentPairs++;
    }
    previousIsLetter = isLetter;
  }
  return letters > 0 && adjacentPairs * 5 >= letters * 2;
}

bool _isCp1251Letter(int b) => b >= 0xC0 || _cp1251ExtraLetters.contains(b);

// Ўў Ґ Ё Є Ї Ііґ ё є ї
const _cp1251ExtraLetters = {
  0xA1, 0xA2, 0xA5, 0xA8, 0xAA, 0xAF, 0xB2, 0xB3, 0xB4, 0xB8, 0xBA, 0xBF, //
};

String _decodeSingleByte(List<int> bytes, List<int> highTable) {
  final buffer = StringBuffer();
  for (final b in bytes) {
    buffer.writeCharCode(b < 0x80 ? b : highTable[b - 0x80]);
  }
  return buffer.toString();
}

String _decodeCp1252(List<int> bytes) {
  final buffer = StringBuffer();
  for (final b in bytes) {
    buffer.writeCharCode(b >= 0x80 && b < 0xA0 ? _cp1252C1[b - 0x80] : b);
  }
  return buffer.toString();
}

const _cp1251High = <int>[
  0x0402, 0x0403, 0x201A, 0x0453, 0x201E, 0x2026, 0x2020, 0x2021, //
  0x20AC, 0x2030, 0x0409, 0x2039, 0x040A, 0x040C, 0x040B, 0x040F,
  0x0452, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
  0xFFFD, 0x2122, 0x0459, 0x203A, 0x045A, 0x045C, 0x045B, 0x045F,
  0x00A0, 0x040E, 0x045E, 0x0408, 0x00A4, 0x0490, 0x00A6, 0x00A7,
  0x0401, 0x00A9, 0x0404, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x0407,
  0x00B0, 0x00B1, 0x0406, 0x0456, 0x0491, 0x00B5, 0x00B6, 0x00B7,
  0x0451, 0x2116, 0x0454, 0x00BB, 0x0458, 0x0405, 0x0455, 0x0457,
  0x0410, 0x0411, 0x0412, 0x0413, 0x0414, 0x0415, 0x0416, 0x0417,
  0x0418, 0x0419, 0x041A, 0x041B, 0x041C, 0x041D, 0x041E, 0x041F,
  0x0420, 0x0421, 0x0422, 0x0423, 0x0424, 0x0425, 0x0426, 0x0427,
  0x0428, 0x0429, 0x042A, 0x042B, 0x042C, 0x042D, 0x042E, 0x042F,
  0x0430, 0x0431, 0x0432, 0x0433, 0x0434, 0x0435, 0x0436, 0x0437,
  0x0438, 0x0439, 0x043A, 0x043B, 0x043C, 0x043D, 0x043E, 0x043F,
  0x0440, 0x0441, 0x0442, 0x0443, 0x0444, 0x0445, 0x0446, 0x0447,
  0x0448, 0x0449, 0x044A, 0x044B, 0x044C, 0x044D, 0x044E, 0x044F,
];

// Windows-1252 differs from Latin-1 only in 0x80–0x9F.
const _cp1252C1 = <int>[
  0x20AC, 0xFFFD, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, //
  0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0xFFFD, 0x017D, 0xFFFD,
  0xFFFD, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
  0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0xFFFD, 0x017E, 0x0178,
];
