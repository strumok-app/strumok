// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceSelectorHash() => r'4751d5fcfff9d640b78ce3cfc65dc646379ccde9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [sourceSelector].
@ProviderFor(sourceSelector)
const sourceSelectorProvider = SourceSelectorFamily();

/// See also [sourceSelector].
class SourceSelectorFamily extends Family<
    AsyncValue<(List<ContentMediaItemSource>, String?, String?)>> {
  /// See also [sourceSelector].
  const SourceSelectorFamily();

  /// See also [sourceSelector].
  SourceSelectorProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return SourceSelectorProvider(
      contentDetails,
      mediaItems,
    );
  }

  @override
  SourceSelectorProvider getProviderOverride(
    covariant SourceSelectorProvider provider,
  ) {
    return call(
      provider.contentDetails,
      provider.mediaItems,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sourceSelectorProvider';
}

/// See also [sourceSelector].
class SourceSelectorProvider extends AutoDisposeFutureProvider<
    (List<ContentMediaItemSource>, String?, String?)> {
  /// See also [sourceSelector].
  SourceSelectorProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
          (ref) => sourceSelector(
            ref as SourceSelectorRef,
            contentDetails,
            mediaItems,
          ),
          from: sourceSelectorProvider,
          name: r'sourceSelectorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sourceSelectorHash,
          dependencies: SourceSelectorFamily._dependencies,
          allTransitiveDependencies:
              SourceSelectorFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
          mediaItems: mediaItems,
        );

  SourceSelectorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
    required this.mediaItems,
  }) : super.internal();

  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  @override
  Override overrideWith(
    FutureOr<(List<ContentMediaItemSource>, String?, String?)> Function(
            SourceSelectorRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SourceSelectorProvider._internal(
        (ref) => create(ref as SourceSelectorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<
      (List<ContentMediaItemSource>, String?, String?)> createElement() {
    return _SourceSelectorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SourceSelectorProvider &&
        other.contentDetails == contentDetails &&
        other.mediaItems == mediaItems;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);
    hash = _SystemHash.combine(hash, mediaItems.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SourceSelectorRef on AutoDisposeFutureProviderRef<
    (List<ContentMediaItemSource>, String?, String?)> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _SourceSelectorProviderElement extends AutoDisposeFutureProviderElement<
    (List<ContentMediaItemSource>, String?, String?)> with SourceSelectorRef {
  _SourceSelectorProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as SourceSelectorProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as SourceSelectorProvider).mediaItems;
}

String _$shuffleModeSettingsHash() =>
    r'4f9d678e0dbacffc8e4ded86d13a44dd301ef298';

/// See also [ShuffleModeSettings].
@ProviderFor(ShuffleModeSettings)
final shuffleModeSettingsProvider =
    AutoDisposeNotifierProvider<ShuffleModeSettings, bool>.internal(
  ShuffleModeSettings.new,
  name: r'shuffleModeSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shuffleModeSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShuffleModeSettings = AutoDisposeNotifier<bool>;
String _$onVideoEndsActionSettingsHash() =>
    r'645262e61474502f40af4f09324292bd26253d41';

/// See also [OnVideoEndsActionSettings].
@ProviderFor(OnVideoEndsActionSettings)
final onVideoEndsActionSettingsProvider = AutoDisposeNotifierProvider<
    OnVideoEndsActionSettings, OnVideoEndsAction>.internal(
  OnVideoEndsActionSettings.new,
  name: r'onVideoEndsActionSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onVideoEndsActionSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnVideoEndsActionSettings = AutoDisposeNotifier<OnVideoEndsAction>;
String _$starVideoPositionSettingsHash() =>
    r'b12d121e7d32acfcce6809d7537e30727220a6f6';

/// See also [StarVideoPositionSettings].
@ProviderFor(StarVideoPositionSettings)
final starVideoPositionSettingsProvider = AutoDisposeNotifierProvider<
    StarVideoPositionSettings, StarVideoPosition>.internal(
  StarVideoPositionSettings.new,
  name: r'starVideoPositionSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$starVideoPositionSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StarVideoPositionSettings = AutoDisposeNotifier<StarVideoPosition>;
String _$fixedPositionSettingsHash() =>
    r'c8eccdf340da4f16b39a9c5fed0d5ebecfdf97fb';

/// See also [FixedPositionSettings].
@ProviderFor(FixedPositionSettings)
final fixedPositionSettingsProvider =
    AutoDisposeNotifierProvider<FixedPositionSettings, int>.internal(
  FixedPositionSettings.new,
  name: r'fixedPositionSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fixedPositionSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FixedPositionSettings = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
