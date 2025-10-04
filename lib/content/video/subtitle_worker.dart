import 'dart:isolate';
import 'package:subtitle/subtitle.dart';

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
  final SubtitleController? controller;
  final String? error;

  SubtitleWorkerResponse.success(this.controller) : error = null;
  SubtitleWorkerResponse.error(this.error) : controller = null;
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
        final controller = await _parseSubtitle(message.uri, message.headers);
        final response = SubtitleWorkerResponse.success(controller);
        message.replyPort.send(response);
      } catch (e) {
        final response = SubtitleWorkerResponse.error(e.toString());
        message.replyPort.send(response);
      }
    }
  });
}

/// Parse subtitle using the subtitle library
Future<SubtitleController> _parseSubtitle(
  String uri,
  Map<String, String>? headers,
) async {
  final controller = SubtitleController(
    provider: NetworkSubtitle(Uri.parse(uri), headers: headers ?? {}),
  );

  // Initialize the controller (this is where the actual parsing happens)
  await controller.initial();

  return controller;
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
  Future<SubtitleController> parseSubtitle(
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

    return response.controller!;
  }

  /// Dispose of the worker isolate
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    _isInitialized = false;
  }
}
