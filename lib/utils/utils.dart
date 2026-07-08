import 'dart:io';
import 'dart:typed_data';

Future<T> retry<T>(
  Future<T> Function() action,
  int maxRetries,
  Duration retryDelay,
) async {
  int attempt = 0;
  while (true) {
    try {
      return await action();
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries) {
        rethrow;
      }
      await Future.delayed(retryDelay);
    }
  }
}

class DisableCertVerifyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

double downloadSpeed(DateTime start, int bytes) {
  final seconds = DateTime.now().difference(start).inSeconds;

  if (seconds > 0) {
    return bytes / seconds.toDouble();
  }

  return 0;
}

Uint8List hexStringToUint8List(String hex) {
  final bytes = <int>[];
  for (int i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return Uint8List.fromList(bytes);
}

Uri relativeUri(Uri baseUri, String url) {
  final streamUri = Uri.parse(url);
  if (streamUri.isAbsolute) {
    return streamUri;
  }

  return baseUri.resolve(url);
}
