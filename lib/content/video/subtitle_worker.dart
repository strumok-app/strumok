import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:strumok/content/video/subtitles/subtitle_decoder.dart';
import 'package:strumok/content/video/subtitles/subtitle_parser.dart';
import 'package:strumok/content/video/subtitles/subtitle_track.dart';

const _connectionTimeout = Duration(seconds: 30);
const _downloadTimeout = Duration(seconds: 60);

/// Message sent to the subtitle worker isolate
class SubtitleWorkerMessage {
  final String uri;
  final Map<String, String>? headers;
  final SendPort replyPort;

  SubtitleWorkerMessage({
    required this.uri,
    required this.headers,
    required this.replyPort,
  });
}

/// Response from the subtitle worker isolate
class SubtitleWorkerResponse {
  final SubtitleTrack? track;
  final String? error;

  SubtitleWorkerResponse.success(this.track) : error = null;
  SubtitleWorkerResponse.error(this.error) : track = null;
}

/// The main function for the subtitle worker isolate
void subtitleWorkerMain(SendPort mainSendPort) {
  final receivePort = ReceivePort();

  // Send the send port back to the main isolate
  mainSendPort.send(receivePort.sendPort);

  // Listen for messages from the main isolate
  receivePort.listen((message) async {
    if (message is SubtitleWorkerMessage) {
      try {
        final track = await _loadSubtitle(message.uri, message.headers);
        final response = SubtitleWorkerResponse.success(track);
        message.replyPort.send(response);
      } catch (e) {
        final response = SubtitleWorkerResponse.error(e.toString());
        message.replyPort.send(response);
      }
    }
  });
}

/// Fetch, decode and parse a subtitle file
Future<SubtitleTrack> _loadSubtitle(
  String uri,
  Map<String, String>? headers,
) async {
  final url = Uri.parse(uri);
  final bytes = url.scheme == 'file'
      ? await File.fromUri(url).readAsBytes()
      : await _download(url, headers);

  return parseSubtitles(decodeSubtitleBytes(bytes));
}

Future<Uint8List> _download(Uri url, Map<String, String>? headers) async {
  final client = HttpClient()..connectionTimeout = _connectionTimeout;

  try {
    final request = await client.getUrl(url);
    headers?.forEach(request.headers.add);

    final response = await request.close().timeout(_downloadTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await response.drain<void>();
      throw HttpException('HTTP ${response.statusCode}', uri: url);
    }

    final builder = BytesBuilder(copy: false);
    await response.forEach(builder.add).timeout(_downloadTimeout);
    return builder.takeBytes();
  } finally {
    client.close(force: true);
  }
}

/// Worker class to manage the subtitle parsing isolate
class SubtitleWorker {
  Isolate? _isolate;
  SendPort? _isolateSendPort;
  ReceivePort? _receivePort;
  bool _isInitialized = false;

  /// Initialize the worker isolate
  Future<void> initialize() async {
    if (_isInitialized) return;

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn<SendPort>(
      subtitleWorkerMain,
      _receivePort!.sendPort,
    );

    // Wait for the isolate to send back its send port
    _isolateSendPort = await _receivePort!.first as SendPort;
    _isInitialized = true;
  }

  /// Parse subtitle using the worker isolate
  Future<SubtitleTrack> parseSubtitle(
    String uri,
    Map<String, String>? headers,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    final responseReceivePort = ReceivePort();
    final message = SubtitleWorkerMessage(
      uri: uri,
      headers: headers,
      replyPort: responseReceivePort.sendPort,
    );

    // Send message to isolate
    _isolateSendPort!.send(message);

    // Wait for response
    final response = await responseReceivePort.first as SubtitleWorkerResponse;

    if (response.error != null) {
      throw Exception('Failed to parse subtitle: ${response.error}');
    }

    return response.track!;
  }

  /// Dispose of the worker isolate
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    _isInitialized = false;
  }
}
