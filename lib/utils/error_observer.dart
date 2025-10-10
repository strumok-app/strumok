import 'package:strumok/utils/logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ErrorProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logger.severe("Provider $provider fails", error, stackTrace);
  }
}
