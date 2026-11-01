import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:strumok/utils/hls.dart';

Uint8List _packets(int count) {
  final bytes = Uint8List(count * 188);
  for (var i = 0; i < count; i++) {
    final offset = i * 188;
    bytes.fillRange(offset, offset + 188, i + 1);
    bytes[offset] = 0x47;
    bytes[offset + 3] = 0x10 | (i % 16);
  }
  return bytes;
}

void main() {
  group('TSJunkFilter', () {
    test('preserves a clean segment across every chunk boundary', () {
      final bytes = _packets(5);
      for (var split = 0; split <= bytes.length; split++) {
        final filter = TSJunkFilter();
        final output = <int>[
          ...?filter.feed(bytes.sublist(0, split)),
          ...?filter.feed(bytes.sublist(split)),
          ...?filter.finish(),
        ];
        expect(output, bytes, reason: 'split=$split');
        expect(filter.filteredBytes, 0);
        expect(filter.pending.length, 0);
      }
    });

    test('confirms sync as soon as the third sync byte arrives', () {
      final bytes = _packets(3);
      final filter = TSJunkFilter();
      expect(filter.feed(bytes.sublist(0, 376)), isNull);
      expect(filter.feed(bytes.sublist(376, 377)), bytes.sublist(0, 377));
      final tail = bytes.sublist(377);
      expect(filter.feed(tail), same(tail));
      expect(filter.finish(), isNull);
    });

    test('strips only a prefix across every chunk boundary', () {
      final packets = _packets(4);
      final junk = List<int>.filled(701, 0x99)..[0] = 0x47;
      final bytes = <int>[...junk, ...packets];
      for (var split = 0; split <= bytes.length; split++) {
        final filter = TSJunkFilter();
        final output = <int>[
          ...?filter.feed(bytes.sublist(0, split)),
          ...?filter.feed(bytes.sublist(split)),
          ...?filter.finish(),
        ];
        expect(output, packets, reason: 'split=$split');
        expect(filter.filteredBytes, junk.length);
      }
    });

    for (final count in [1, 2]) {
      for (final junkLength in [0, 17, 701]) {
        test('flushes $count packets with $junkLength prefix bytes', () {
          final packets = _packets(count);
          final filter = TSJunkFilter();
          final output = <int>[];
          for (final byte in [
            ...List<int>.filled(junkLength, 0x99),
            ...packets,
          ]) {
            output.addAll(filter.feed([byte]) ?? []);
          }
          output.addAll(filter.finish() ?? []);
          expect(output, packets);
          expect(filter.syncFound, isTrue);
          expect(filter.filteredBytes, junkLength);
          expect(filter.pending.length, 0);
        });
      }
    }

    test('does not flush truncated or non-TS data', () {
      for (final bytes in [
        <int>[],
        List<int>.filled(800, 0x99),
        _packets(1).sublist(0, 187),
        Uint8List(188)..[0] = 0x47,
      ]) {
        final filter = TSJunkFilter();
        expect(filter.feed(bytes), isNull);
        expect(filter.finish, throwsFormatException);
        expect(filter.syncFound, isFalse);
      }
    });
  });
}
