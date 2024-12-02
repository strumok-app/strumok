import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:strumok/utils/logger.dart';

void traceError({
  required dynamic error,
  dynamic stackTrace,
  String? msg,
}) {
  Sentry.captureException(
    error,
    stackTrace: stackTrace,
    hint: Hint.withMap({"message": msg}),
  );

  if (msg != null) {
    logger.e(msg, error: error, stackTrace: stackTrace);
  }
}
