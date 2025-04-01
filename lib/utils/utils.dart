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
