import 'package:strumok/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void traceError({required dynamic error, dynamic stackTrace, String? message}) {
  Sentry.captureException(
    error,
    stackTrace: stackTrace,
    hint: Hint.withMap({"message": message}),
  );

  if (message != null) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}
