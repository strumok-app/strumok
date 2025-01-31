import 'package:strumok/utils/logger.dart';

void traceError({
  required dynamic error,
  dynamic stackTrace,
  String? message,
}) {
  // Sentry.captureException(
  //   error,
  //   stackTrace: stackTrace,
  //   hint: Hint.withMap({"message": message}),
  // );

  if (message != null) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}

void traceAction(
  String action, {
  String? description,
}) {
  // Sentry.getSpan()?.startChild(action, description: description).finish();
}
