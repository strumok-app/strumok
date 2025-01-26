// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detailsHash() => r'ce14752954161a706ee4e7e8c98d02a06087ff5a';

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

/// See also [details].
@ProviderFor(details)
const detailsProvider = DetailsFamily();

/// See also [details].
class DetailsFamily extends Family<AsyncValue<ContentDetails>> {
  /// See also [details].
  const DetailsFamily();

  /// See also [details].
  DetailsProvider call(
    String supplier,
    String id,
  ) {
    return DetailsProvider(
      supplier,
      id,
    );
  }

  @override
  DetailsProvider getProviderOverride(
    covariant DetailsProvider provider,
  ) {
    return call(
      provider.supplier,
      provider.id,
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
  String? get name => r'detailsProvider';
}

/// See also [details].
class DetailsProvider extends AutoDisposeFutureProvider<ContentDetails> {
  /// See also [details].
  DetailsProvider(
    String supplier,
    String id,
  ) : this._internal(
          (ref) => details(
            ref as DetailsRef,
            supplier,
            id,
          ),
          from: detailsProvider,
          name: r'detailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$detailsHash,
          dependencies: DetailsFamily._dependencies,
          allTransitiveDependencies: DetailsFamily._allTransitiveDependencies,
          supplier: supplier,
          id: id,
        );

  DetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplier,
    required this.id,
  }) : super.internal();

  final String supplier;
  final String id;

  @override
  Override overrideWith(
    FutureOr<ContentDetails> Function(DetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DetailsProvider._internal(
        (ref) => create(ref as DetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplier: supplier,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ContentDetails> createElement() {
    return _DetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailsProvider &&
        other.supplier == supplier &&
        other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplier.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DetailsRef on AutoDisposeFutureProviderRef<ContentDetails> {
  /// The parameter `supplier` of this provider.
  String get supplier;

  /// The parameter `id` of this provider.
  String get id;
}

class _DetailsProviderElement
    extends AutoDisposeFutureProviderElement<ContentDetails> with DetailsRef {
  _DetailsProviderElement(super.provider);

  @override
  String get supplier => (origin as DetailsProvider).supplier;
  @override
  String get id => (origin as DetailsProvider).id;
}

String _$detailsAndMediaHash() => r'ab4645c5fe8819a10cb5024d67f0ed9e16c14de4';

/// See also [detailsAndMedia].
@ProviderFor(detailsAndMedia)
const detailsAndMediaProvider = DetailsAndMediaFamily();

/// See also [detailsAndMedia].
class DetailsAndMediaFamily extends Family<AsyncValue<DetailsAndMediaItems>> {
  /// See also [detailsAndMedia].
  const DetailsAndMediaFamily();

  /// See also [detailsAndMedia].
  DetailsAndMediaProvider call(
    String supplier,
    String id,
  ) {
    return DetailsAndMediaProvider(
      supplier,
      id,
    );
  }

  @override
  DetailsAndMediaProvider getProviderOverride(
    covariant DetailsAndMediaProvider provider,
  ) {
    return call(
      provider.supplier,
      provider.id,
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
  String? get name => r'detailsAndMediaProvider';
}

/// See also [detailsAndMedia].
class DetailsAndMediaProvider
    extends AutoDisposeFutureProvider<DetailsAndMediaItems> {
  /// See also [detailsAndMedia].
  DetailsAndMediaProvider(
    String supplier,
    String id,
  ) : this._internal(
          (ref) => detailsAndMedia(
            ref as DetailsAndMediaRef,
            supplier,
            id,
          ),
          from: detailsAndMediaProvider,
          name: r'detailsAndMediaProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$detailsAndMediaHash,
          dependencies: DetailsAndMediaFamily._dependencies,
          allTransitiveDependencies:
              DetailsAndMediaFamily._allTransitiveDependencies,
          supplier: supplier,
          id: id,
        );

  DetailsAndMediaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplier,
    required this.id,
  }) : super.internal();

  final String supplier;
  final String id;

  @override
  Override overrideWith(
    FutureOr<DetailsAndMediaItems> Function(DetailsAndMediaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DetailsAndMediaProvider._internal(
        (ref) => create(ref as DetailsAndMediaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplier: supplier,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DetailsAndMediaItems> createElement() {
    return _DetailsAndMediaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailsAndMediaProvider &&
        other.supplier == supplier &&
        other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplier.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DetailsAndMediaRef on AutoDisposeFutureProviderRef<DetailsAndMediaItems> {
  /// The parameter `supplier` of this provider.
  String get supplier;

  /// The parameter `id` of this provider.
  String get id;
}

class _DetailsAndMediaProviderElement
    extends AutoDisposeFutureProviderElement<DetailsAndMediaItems>
    with DetailsAndMediaRef {
  _DetailsAndMediaProviderElement(super.provider);

  @override
  String get supplier => (origin as DetailsAndMediaProvider).supplier;
  @override
  String get id => (origin as DetailsAndMediaProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
