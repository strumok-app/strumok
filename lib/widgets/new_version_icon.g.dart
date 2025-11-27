// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_version_icon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hasNewVersion)
const hasNewVersionProvider = HasNewVersionProvider._();

final class HasNewVersionProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const HasNewVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasNewVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasNewVersionHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasNewVersion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasNewVersionHash() => r'c59064f914a68646e5d36ae4aa8f2145646929bc';
