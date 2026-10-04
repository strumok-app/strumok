import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:strumok/utils/utils.dart';

class HLSManifest {
  final Uri uri;
  final List<HLSStream> streams;
  final List<HLSSegment> segments;

  HLSManifest({
    required this.uri,
    required this.streams,
    required this.segments,
  });

  @override
  String toString() {
    return 'HLSManifest{uri: $uri, streams: $streams, segmentsLength: ${segments.length}}';
  }
}

class HLSStream {
  final Uri uri;
  final int bandwidth;
  final int? width;
  final int? height;

  HLSStream({
    required this.uri,
    required this.bandwidth,
    this.width,
    this.height,
  });

  @override
  String toString() {
    return 'HLSStream{uri: $uri, bandwidth: $bandwidth, width: $width, height: $height}';
  }
}

class HLSSegment {
  final Uri uri;
  final HLSKey? encryptionKey;
  final HLSByteRange? byteRange;

  /// fMP4 initialization section (EXT-X-MAP); null for MPEG-TS segments.
  final HLSInitSegment? initSegment;

  HLSSegment({
    required this.uri,
    this.encryptionKey,
    this.byteRange,
    this.initSegment,
  });

  bool get isFMP4 => initSegment != null;

  @override
  String toString() {
    return 'HLSSegment{uri: $uri, encryptionKey: $encryptionKey, byteRange: $byteRange, initSegment: $initSegment}';
  }
}

class HLSInitSegment {
  final Uri uri;
  final HLSByteRange? byteRange;
  final HLSKey? encryptionKey;

  HLSInitSegment({required this.uri, this.byteRange, this.encryptionKey});

  @override
  bool operator ==(Object other) =>
      other is HLSInitSegment &&
      other.uri == uri &&
      other.byteRange == byteRange;

  @override
  int get hashCode => Object.hash(uri, byteRange);

  @override
  String toString() {
    return 'HLSInitSegment{uri: $uri, byteRange: $byteRange, encryptionKey: $encryptionKey}';
  }
}

class HLSByteRange {
  final int length;
  final int offset;

  HLSByteRange({required this.length, required this.offset});

  String get rangeHeader => 'bytes=$offset-${offset + length - 1}';

  @override
  bool operator ==(Object other) =>
      other is HLSByteRange && other.length == length && other.offset == offset;

  @override
  int get hashCode => Object.hash(length, offset);

  @override
  String toString() => '$length@$offset';
}

class HLSKey {
  final String method;
  final Uri uri;
  final Uint8List? iv;

  HLSKey({required this.method, required this.uri, this.iv});

  @override
  String toString() {
    return 'HLSKey{method: $method, uri: $uri, iv: $iv}';
  }
}

class HLSDecryptor {
  final BlockCipher cipher;

  HLSDecryptor(Uint8List key, Uint8List? iv)
    : cipher = PaddedBlockCipher("AES/CBC/PKCS7")
        ..init(
          false,
          PaddedBlockCipherParameters(
            ParametersWithIV(KeyParameter(key), iv ?? Uint8List(16)),
            null,
          ),
        );

  Uint8List decrypt(Uint8List data) {
    return cipher.process(data);
  }
}

Future<HLSManifest> parseHLSManifest(Uri uri, String content) async {
  final List<HLSStream> streams = [];
  final List<HLSSegment> segments = [];
  HLSKey? encryptionKey;
  HLSKey? activeKey;
  HLSInitSegment? initSegment;
  String? pendingByteRange;
  Uri? lastRangeUri;
  int lastRangeEnd = 0;
  final lines = content.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('#')) {
      if (line.startsWith("#EXT-X-KEY:")) {
        encryptionKey = await parseHLSKey(uri, line);
        activeKey = encryptionKey;
      } else if (line.startsWith("#EXT-X-MAP:")) {
        final attrs = _parseAttributes(line.substring(11));
        final mapUri = attrs['URI'];
        if (mapUri != null) {
          final rangeAttr = attrs['BYTERANGE'];
          initSegment = HLSInitSegment(
            uri: relativeUri(uri, mapUri),
            byteRange: rangeAttr != null ? _parseByteRange(rangeAttr, 0) : null,
            encryptionKey: activeKey,
          );
        }
      } else if (line.startsWith("#EXT-X-BYTERANGE:")) {
        pendingByteRange = line.substring(17).trim();
      } else if (line.startsWith("#EXT-X-STREAM-INF:")) {
        final attrs = line.split(':').last.split(',');
        int? bandwidth;
        int? width;
        int? height;

        for (final attr in attrs) {
          final parts = attr.split('=');
          if (parts[0] == 'BANDWIDTH') {
            bandwidth = int.parse(parts[1]);
          } else if (parts[0] == 'RESOLUTION') {
            final res = parts[1].split('x');
            width = int.parse(res[0]);
            height = int.parse(res[1]);
          }
        }

        if (bandwidth != null && i < lines.length - 1) {
          streams.add(
            HLSStream(
              uri: relativeUri(uri, lines[++i]),
              bandwidth: bandwidth,
              width: width,
              height: height,
            ),
          );
        }
      }
    } else {
      final segmentUri = relativeUri(uri, line);
      HLSByteRange? byteRange;
      if (pendingByteRange != null) {
        // Without explicit offset the range continues from the previous sub-range of the same resource.
        final defaultOffset = lastRangeUri == segmentUri ? lastRangeEnd : 0;
        byteRange = _parseByteRange(pendingByteRange, defaultOffset);
        lastRangeUri = segmentUri;
        lastRangeEnd = byteRange.offset + byteRange.length;
        pendingByteRange = null;
      }

      segments.add(
        HLSSegment(
          uri: segmentUri,
          encryptionKey: encryptionKey,
          byteRange: byteRange,
          initSegment: initSegment,
        ),
      );
      encryptionKey = null;
    }
  }

  return HLSManifest(uri: uri, streams: streams, segments: segments);
}

HLSByteRange _parseByteRange(String value, int defaultOffset) {
  final parts = value.replaceAll('"', '').split('@');
  return HLSByteRange(
    length: int.parse(parts[0].trim()),
    offset: parts.length > 1 ? int.parse(parts[1].trim()) : defaultOffset,
  );
}

Map<String, String> _parseAttributes(String attrs) {
  final result = <String, String>{};
  final regex = RegExp(r'([A-Z0-9-]+)=("[^"]*"|[^,]*)');
  for (final match in regex.allMatches(attrs)) {
    result[match.group(1)!] = match.group(2)!.replaceAll('"', '').trim();
  }
  return result;
}

Future<HLSKey?> parseHLSKey(Uri masterUri, String keyLine) async {
  if (!keyLine.startsWith('#EXT-X-KEY:')) return null;

  final attrs = keyLine.substring(11).split(',');
  String? method;
  String? uri;
  Uint8List? iv;

  for (final attr in attrs) {
    final parts = attr.split('=');
    if (parts.length != 2) continue;

    final key = parts[0].trim();
    final value = parts[1].replaceAll('"', '').trim();

    if (key == 'METHOD') {
      method = value;
    } else if (key == 'URI') {
      uri = value;
    } else if (key == 'IV') {
      iv = hexStringToUint8List(value.substring(2));
    }
  }

  if (method != 'AES-128' || uri == null) return null;

  return HLSKey(method: method!, uri: relativeUri(masterUri, uri), iv: iv);
}

// -----------------------------------------------------------------------
// MPEG-TS junk stripping
//
// Some CDNs prepend a 1×1 PNG tracking pixel (or other garbage) before
// the real TS data. We buffer chunks until we have at least
// 3 × 188 = 564 bytes, then locate the first offset where three
// consecutive 0x47 bytes are exactly 188 bytes apart. Everything before
// that offset is discarded. Once the sync is confirmed we switch to
// direct passthrough with no extra buffering.
// -----------------------------------------------------------------------

class TSJunkFilter {
  // TS packet size in bytes (ISO 13818-1).
  static const int _kTsPacketSize = 188;

  // MPEG-TS sync byte.
  static const int _kTsSyncByte = 0x47;

  /// Returns the offset of the first *confirmed* MPEG-TS sync position in
  /// [bytes], or -1 if none is found.
  ///
  /// "Confirmed" means three consecutive 0x47 bytes spaced exactly
  /// [_kTsPacketSize] bytes apart, which virtually eliminates the chance of
  /// a false positive from random data.
  int _findTsSyncOffset(Uint8List bytes) {
    for (int i = 0; i + 2 * _kTsPacketSize < bytes.length; i++) {
      if (bytes[i] == _kTsSyncByte &&
          bytes[i + _kTsPacketSize] == _kTsSyncByte &&
          bytes[i + 2 * _kTsPacketSize] == _kTsSyncByte) {
        return i;
      }
    }
    return -1;
  }

  bool syncFound = false;
  final pending = BytesBuilder();
  int filteredBytes = 0;

  /// Feeds a chunk of bytes into the filter. Returns the portion of the chunk that should be forwarded to the client (i.e. with any leading junk stripped).
  List<int>? feed(List<int> chunk) {
    if (syncFound) {
      // Already past junk – write directly to client.
      return chunk;
    }

    pending.add(chunk);

    // Wait until we have enough data to confirm a sync at position 0.
    if (pending.length < 3 * _kTsPacketSize) return null;

    final bytes = pending.toBytes();
    final syncOffset = _findTsSyncOffset(bytes);

    if (syncOffset >= 0) {
      syncFound = true;
      filteredBytes = syncOffset;
      // Use the accumulated buffer, not just the latest chunk, since the
      // sync offset is relative to all bytes buffered so far.
      return bytes.sublist(syncOffset);
    }

    // else: keep buffering until the next chunk arrives.
    return null;
  }
}
