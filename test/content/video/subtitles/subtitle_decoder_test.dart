import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:strumok/content/video/subtitles/subtitle_decoder.dart';

List<int> _utf16(String text, {required bool littleEndian, bool bom = false}) {
  final bytes = <int>[
    if (bom && littleEndian) ...[0xFF, 0xFE],
    if (bom && !littleEndian) ...[0xFE, 0xFF],
  ];
  for (final unit in text.codeUnits) {
    final hi = unit >> 8;
    final lo = unit & 0xFF;
    bytes.addAll(littleEndian ? [lo, hi] : [hi, lo]);
  }
  return bytes;
}

void main() {
  const sample =
      '1\n00:00:01,000 --> 00:00:02,000\nПривіт, світе! Ґанок їжак є\n';

  group('decodeSubtitleBytes', () {
    test('decodes UTF-8', () {
      expect(decodeSubtitleBytes(utf8.encode(sample)), sample);
    });

    test('strips UTF-8 BOM', () {
      expect(
        decodeSubtitleBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(sample)]),
        sample,
      );
    });

    test('decodes UTF-16 LE and BE with BOM', () {
      expect(
        decodeSubtitleBytes(_utf16(sample, littleEndian: true, bom: true)),
        sample,
      );
      expect(
        decodeSubtitleBytes(_utf16(sample, littleEndian: false, bom: true)),
        sample,
      );
    });

    test('decodes BOM-less UTF-16 LE and BE', () {
      const ascii = '1\n00:00:01,000 --> 00:00:02,000\nHello world\n';
      expect(decodeSubtitleBytes(_utf16(ascii, littleEndian: true)), ascii);
      expect(decodeSubtitleBytes(_utf16(ascii, littleEndian: false)), ascii);
    });

    test('falls back to Windows-1251 for Cyrillic legacy files', () {
      // "Привіт, світе! Ґанок їжак є Ёё №" in Windows-1251.
      final bytes = [
        0xCF, 0xF0, 0xE8, 0xE2, 0xB3, 0xF2, 0x2C, 0x20, //
        0xF1, 0xE2, 0xB3, 0xF2, 0xE5, 0x21, 0x20,
        0xA5, 0xE0, 0xED, 0xEE, 0xEA, 0x20,
        0xBF, 0xE6, 0xE0, 0xEA, 0x20, 0xBA, 0x20,
        0xA8, 0xB8, 0x20, 0xB9,
      ];
      expect(decodeSubtitleBytes(bytes), 'Привіт, світе! Ґанок їжак є Ёё №');
    });

    test('falls back to Windows-1252 for Western legacy files', () {
      // "Café “déjà vu” – naïve" in Windows-1252.
      final bytes = [
        ...latin1.encode('Caf'), 0xE9, 0x20, 0x93, //
        ...latin1.encode('d'), 0xE9, ...latin1.encode('j'), 0xE0,
        ...latin1.encode(' vu'), 0x94, 0x20, 0x96,
        ...latin1.encode(' na'), 0xEF, ...latin1.encode('ve'),
      ];
      expect(decodeSubtitleBytes(bytes), 'Café “déjà vu” – naïve');
    });

    test('keeps accent-heavy Western text as Windows-1252', () {
      const french = 'Été déjà à côté, ça a été très élevé.';
      const german = 'Größe, Übermäßig, schön, Straße.';
      expect(decodeSubtitleBytes(latin1.encode(french)), french);
      expect(decodeSubtitleBytes(latin1.encode(german)), german);
    });

    test('handles empty input', () {
      expect(decodeSubtitleBytes(const []), '');
    });
  });
}
