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

double downloadSpeed(DateTime start, int bytes) {
  final seconds = DateTime.now().difference(start).inSeconds;

  if (seconds > 0) {
    return bytes / seconds.toDouble();
  }

  return 0;
}
