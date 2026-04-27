// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(isAISearchAvaliable)
final isAISearchAvaliableProvider = IsAISearchAvaliableProvider._();

final class IsAISearchAvaliableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsAISearchAvaliableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAISearchAvaliableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAISearchAvaliableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAISearchAvaliable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAISearchAvaliableHash() =>
    r'e906726ad25661f6c89d8510ca8d4a32d8d2b64f';

@ProviderFor(AIChat)
final aIChatProvider = AIChatProvider._();

final class AIChatProvider extends $NotifierProvider<AIChat, AIChatState> {
  AIChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aIChatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aIChatHash();

  @$internal
  @override
  AIChat create() => AIChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIChatState>(value),
    );
  }
}

String _$aIChatHash() => r'264ce318c8cb209d47462dadd9fd0deea8f5d0f8';

abstract class _$AIChat extends $Notifier<AIChatState> {
  AIChatState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AIChatState, AIChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AIChatState, AIChatState>,
              AIChatState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
