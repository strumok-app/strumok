// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recommendationChannelHash() =>
    r'f799d0132222bd60ac039fcb82d0758a39745476';

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

abstract class _$RecommendationChannel
    extends BuildlessAsyncNotifier<RecommendationChannelState> {
  late final String supplierName;
  late final String channel;

  FutureOr<RecommendationChannelState> build(
    String supplierName,
    String channel,
  );
}

/// See also [RecommendationChannel].
@ProviderFor(RecommendationChannel)
const recommendationChannelProvider = RecommendationChannelFamily();

/// See also [RecommendationChannel].
class RecommendationChannelFamily
    extends Family<AsyncValue<RecommendationChannelState>> {
  /// See also [RecommendationChannel].
  const RecommendationChannelFamily();

  /// See also [RecommendationChannel].
  RecommendationChannelProvider call(
    String supplierName,
    String channel,
  ) {
    return RecommendationChannelProvider(
      supplierName,
      channel,
    );
  }

  @override
  RecommendationChannelProvider getProviderOverride(
    covariant RecommendationChannelProvider provider,
  ) {
    return call(
      provider.supplierName,
      provider.channel,
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
  String? get name => r'recommendationChannelProvider';
}

/// See also [RecommendationChannel].
class RecommendationChannelProvider extends AsyncNotifierProviderImpl<
    RecommendationChannel, RecommendationChannelState> {
  /// See also [RecommendationChannel].
  RecommendationChannelProvider(
    String supplierName,
    String channel,
  ) : this._internal(
          () => RecommendationChannel()
            ..supplierName = supplierName
            ..channel = channel,
          from: recommendationChannelProvider,
          name: r'recommendationChannelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recommendationChannelHash,
          dependencies: RecommendationChannelFamily._dependencies,
          allTransitiveDependencies:
              RecommendationChannelFamily._allTransitiveDependencies,
          supplierName: supplierName,
          channel: channel,
        );

  RecommendationChannelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplierName,
    required this.channel,
  }) : super.internal();

  final String supplierName;
  final String channel;

  @override
  FutureOr<RecommendationChannelState> runNotifierBuild(
    covariant RecommendationChannel notifier,
  ) {
    return notifier.build(
      supplierName,
      channel,
    );
  }

  @override
  Override overrideWith(RecommendationChannel Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecommendationChannelProvider._internal(
        () => create()
          ..supplierName = supplierName
          ..channel = channel,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplierName: supplierName,
        channel: channel,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<RecommendationChannel,
      RecommendationChannelState> createElement() {
    return _RecommendationChannelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationChannelProvider &&
        other.supplierName == supplierName &&
        other.channel == channel;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplierName.hashCode);
    hash = _SystemHash.combine(hash, channel.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecommendationChannelRef
    on AsyncNotifierProviderRef<RecommendationChannelState> {
  /// The parameter `supplierName` of this provider.
  String get supplierName;

  /// The parameter `channel` of this provider.
  String get channel;
}

class _RecommendationChannelProviderElement
    extends AsyncNotifierProviderElement<RecommendationChannel,
        RecommendationChannelState> with RecommendationChannelRef {
  _RecommendationChannelProviderElement(super.provider);

  @override
  String get supplierName =>
      (origin as RecommendationChannelProvider).supplierName;
  @override
  String get channel => (origin as RecommendationChannelProvider).channel;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
