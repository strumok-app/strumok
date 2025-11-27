import 'package:strumok/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ErrorProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    logger.severe("Provider ${context.provider} fails", error, stackTrace);
  }
}
