// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionItemCurrentItemHash() =>
    r'4bcd51cabe77270f827bf5d2744bd465ca299de7';

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

/// See also [collectionItemCurrentItem].
@ProviderFor(collectionItemCurrentItem)
const collectionItemCurrentItemProvider = CollectionItemCurrentItemFamily();

/// See also [collectionItemCurrentItem].
class CollectionItemCurrentItemFamily extends Family<AsyncValue<int>> {
  /// See also [collectionItemCurrentItem].
  const CollectionItemCurrentItemFamily();

  /// See also [collectionItemCurrentItem].
  CollectionItemCurrentItemProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentItemProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentItemProvider getProviderOverride(
    covariant CollectionItemCurrentItemProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentItemProvider';
}

/// See also [collectionItemCurrentItem].
class CollectionItemCurrentItemProvider extends AutoDisposeFutureProvider<int> {
  /// See also [collectionItemCurrentItem].
  CollectionItemCurrentItemProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentItem(
            ref as CollectionItemCurrentItemRef,
            contentDetails,
          ),
          from: collectionItemCurrentItemProvider,
          name: r'collectionItemCurrentItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentItemHash,
          dependencies: CollectionItemCurrentItemFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemCurrentItemFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<int> Function(CollectionItemCurrentItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentItemProvider._internal(
        (ref) => create(ref as CollectionItemCurrentItemRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _CollectionItemCurrentItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentItemProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionItemCurrentItemRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentItemProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with CollectionItemCurrentItemRef {
  _CollectionItemCurrentItemProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentItemProvider).contentDetails;
}

String _$collectionItemCurrentSourceNameHash() =>
    r'147f53b1ccf9d4b85b17ea67338a62118f21ca28';

/// See also [collectionItemCurrentSourceName].
@ProviderFor(collectionItemCurrentSourceName)
const collectionItemCurrentSourceNameProvider =
    CollectionItemCurrentSourceNameFamily();

/// See also [collectionItemCurrentSourceName].
class CollectionItemCurrentSourceNameFamily
    extends Family<AsyncValue<String?>> {
  /// See also [collectionItemCurrentSourceName].
  const CollectionItemCurrentSourceNameFamily();

  /// See also [collectionItemCurrentSourceName].
  CollectionItemCurrentSourceNameProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentSourceNameProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentSourceNameProvider getProviderOverride(
    covariant CollectionItemCurrentSourceNameProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentSourceNameProvider';
}

/// See also [collectionItemCurrentSourceName].
class CollectionItemCurrentSourceNameProvider
    extends AutoDisposeFutureProvider<String?> {
  /// See also [collectionItemCurrentSourceName].
  CollectionItemCurrentSourceNameProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentSourceName(
            ref as CollectionItemCurrentSourceNameRef,
            contentDetails,
          ),
          from: collectionItemCurrentSourceNameProvider,
          name: r'collectionItemCurrentSourceNameProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentSourceNameHash,
          dependencies: CollectionItemCurrentSourceNameFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemCurrentSourceNameFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentSourceNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<String?> Function(CollectionItemCurrentSourceNameRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentSourceNameProvider._internal(
        (ref) => create(ref as CollectionItemCurrentSourceNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _CollectionItemCurrentSourceNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentSourceNameProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionItemCurrentSourceNameRef
    on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentSourceNameProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with CollectionItemCurrentSourceNameRef {
  _CollectionItemCurrentSourceNameProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentSourceNameProvider).contentDetails;
}

String _$collectionItemCurrentSubtitleNameHash() =>
    r'68eab394d55d3de3752e218209e75e936bd280bb';

/// See also [collectionItemCurrentSubtitleName].
@ProviderFor(collectionItemCurrentSubtitleName)
const collectionItemCurrentSubtitleNameProvider =
    CollectionItemCurrentSubtitleNameFamily();

/// See also [collectionItemCurrentSubtitleName].
class CollectionItemCurrentSubtitleNameFamily
    extends Family<AsyncValue<String?>> {
  /// See also [collectionItemCurrentSubtitleName].
  const CollectionItemCurrentSubtitleNameFamily();

  /// See also [collectionItemCurrentSubtitleName].
  CollectionItemCurrentSubtitleNameProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentSubtitleNameProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentSubtitleNameProvider getProviderOverride(
    covariant CollectionItemCurrentSubtitleNameProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentSubtitleNameProvider';
}

/// See also [collectionItemCurrentSubtitleName].
class CollectionItemCurrentSubtitleNameProvider
    extends AutoDisposeFutureProvider<String?> {
  /// See also [collectionItemCurrentSubtitleName].
  CollectionItemCurrentSubtitleNameProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentSubtitleName(
            ref as CollectionItemCurrentSubtitleNameRef,
            contentDetails,
          ),
          from: collectionItemCurrentSubtitleNameProvider,
          name: r'collectionItemCurrentSubtitleNameProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentSubtitleNameHash,
          dependencies: CollectionItemCurrentSubtitleNameFamily._dependencies,
          allTransitiveDependencies: CollectionItemCurrentSubtitleNameFamily
              ._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentSubtitleNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<String?> Function(CollectionItemCurrentSubtitleNameRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentSubtitleNameProvider._internal(
        (ref) => create(ref as CollectionItemCurrentSubtitleNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _CollectionItemCurrentSubtitleNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentSubtitleNameProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionItemCurrentSubtitleNameRef
    on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentSubtitleNameProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with CollectionItemCurrentSubtitleNameRef {
  _CollectionItemCurrentSubtitleNameProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentSubtitleNameProvider).contentDetails;
}

String _$collectionItemCurrentPositionHash() =>
    r'a40836469154592616c1cad035aad4ec50bc12a7';

/// See also [collectionItemCurrentPosition].
@ProviderFor(collectionItemCurrentPosition)
const collectionItemCurrentPositionProvider =
    CollectionItemCurrentPositionFamily();

/// See also [collectionItemCurrentPosition].
class CollectionItemCurrentPositionFamily extends Family<AsyncValue<int>> {
  /// See also [collectionItemCurrentPosition].
  const CollectionItemCurrentPositionFamily();

  /// See also [collectionItemCurrentPosition].
  CollectionItemCurrentPositionProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentPositionProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentPositionProvider getProviderOverride(
    covariant CollectionItemCurrentPositionProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentPositionProvider';
}

/// See also [collectionItemCurrentPosition].
class CollectionItemCurrentPositionProvider
    extends AutoDisposeFutureProvider<int> {
  /// See also [collectionItemCurrentPosition].
  CollectionItemCurrentPositionProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentPosition(
            ref as CollectionItemCurrentPositionRef,
            contentDetails,
          ),
          from: collectionItemCurrentPositionProvider,
          name: r'collectionItemCurrentPositionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentPositionHash,
          dependencies: CollectionItemCurrentPositionFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemCurrentPositionFamily._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentPositionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<int> Function(CollectionItemCurrentPositionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentPositionProvider._internal(
        (ref) => create(ref as CollectionItemCurrentPositionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _CollectionItemCurrentPositionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentPositionProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionItemCurrentPositionRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentPositionProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with CollectionItemCurrentPositionRef {
  _CollectionItemCurrentPositionProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentPositionProvider).contentDetails;
}

String _$collectionItemCurrentMediaItemPositionHash() =>
    r'd9b0a27f79968b4bd704411a97e1261fe9fca59e';

/// See also [collectionItemCurrentMediaItemPosition].
@ProviderFor(collectionItemCurrentMediaItemPosition)
const collectionItemCurrentMediaItemPositionProvider =
    CollectionItemCurrentMediaItemPositionFamily();

/// See also [collectionItemCurrentMediaItemPosition].
class CollectionItemCurrentMediaItemPositionFamily
    extends Family<AsyncValue<MediaItemPosition>> {
  /// See also [collectionItemCurrentMediaItemPosition].
  const CollectionItemCurrentMediaItemPositionFamily();

  /// See also [collectionItemCurrentMediaItemPosition].
  CollectionItemCurrentMediaItemPositionProvider call(
    ContentDetails contentDetails,
  ) {
    return CollectionItemCurrentMediaItemPositionProvider(
      contentDetails,
    );
  }

  @override
  CollectionItemCurrentMediaItemPositionProvider getProviderOverride(
    covariant CollectionItemCurrentMediaItemPositionProvider provider,
  ) {
    return call(
      provider.contentDetails,
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
  String? get name => r'collectionItemCurrentMediaItemPositionProvider';
}

/// See also [collectionItemCurrentMediaItemPosition].
class CollectionItemCurrentMediaItemPositionProvider
    extends AutoDisposeFutureProvider<MediaItemPosition> {
  /// See also [collectionItemCurrentMediaItemPosition].
  CollectionItemCurrentMediaItemPositionProvider(
    ContentDetails contentDetails,
  ) : this._internal(
          (ref) => collectionItemCurrentMediaItemPosition(
            ref as CollectionItemCurrentMediaItemPositionRef,
            contentDetails,
          ),
          from: collectionItemCurrentMediaItemPositionProvider,
          name: r'collectionItemCurrentMediaItemPositionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemCurrentMediaItemPositionHash,
          dependencies:
              CollectionItemCurrentMediaItemPositionFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemCurrentMediaItemPositionFamily
                  ._allTransitiveDependencies,
          contentDetails: contentDetails,
        );

  CollectionItemCurrentMediaItemPositionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentDetails,
  }) : super.internal();

  final ContentDetails contentDetails;

  @override
  Override overrideWith(
    FutureOr<MediaItemPosition> Function(
            CollectionItemCurrentMediaItemPositionRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemCurrentMediaItemPositionProvider._internal(
        (ref) => create(ref as CollectionItemCurrentMediaItemPositionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentDetails: contentDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MediaItemPosition> createElement() {
    return _CollectionItemCurrentMediaItemPositionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentMediaItemPositionProvider &&
        other.contentDetails == contentDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionItemCurrentMediaItemPositionRef
    on AutoDisposeFutureProviderRef<MediaItemPosition> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;
}

class _CollectionItemCurrentMediaItemPositionProviderElement
    extends AutoDisposeFutureProviderElement<MediaItemPosition>
    with CollectionItemCurrentMediaItemPositionRef {
  _CollectionItemCurrentMediaItemPositionProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CollectionItemCurrentMediaItemPositionProvider).contentDetails;
}

String _$collectionItemHash() => r'5c6a8d81ef63b02f3d413c74a586bdbdd529fab6';

abstract class _$CollectionItem
    extends BuildlessAutoDisposeAsyncNotifier<MediaCollectionItem> {
  late final ContentDetails details;

  FutureOr<MediaCollectionItem> build(
    ContentDetails details,
  );
}

/// See also [CollectionItem].
@ProviderFor(CollectionItem)
const collectionItemProvider = CollectionItemFamily();

/// See also [CollectionItem].
class CollectionItemFamily extends Family<AsyncValue<MediaCollectionItem>> {
  /// See also [CollectionItem].
  const CollectionItemFamily();

  /// See also [CollectionItem].
  CollectionItemProvider call(
    ContentDetails details,
  ) {
    return CollectionItemProvider(
      details,
    );
  }

  @override
  CollectionItemProvider getProviderOverride(
    covariant CollectionItemProvider provider,
  ) {
    return call(
      provider.details,
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
  String? get name => r'collectionItemProvider';
}

/// See also [CollectionItem].
class CollectionItemProvider extends AutoDisposeAsyncNotifierProviderImpl<
    CollectionItem, MediaCollectionItem> {
  /// See also [CollectionItem].
  CollectionItemProvider(
    ContentDetails details,
  ) : this._internal(
          () => CollectionItem()..details = details,
          from: collectionItemProvider,
          name: r'collectionItemProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$collectionItemHash,
          dependencies: CollectionItemFamily._dependencies,
          allTransitiveDependencies:
              CollectionItemFamily._allTransitiveDependencies,
          details: details,
        );

  CollectionItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.details,
  }) : super.internal();

  final ContentDetails details;

  @override
  FutureOr<MediaCollectionItem> runNotifierBuild(
    covariant CollectionItem notifier,
  ) {
    return notifier.build(
      details,
    );
  }

  @override
  Override overrideWith(CollectionItem Function() create) {
    return ProviderOverride(
      origin: this,
      override: CollectionItemProvider._internal(
        () => create()..details = details,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        details: details,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CollectionItem, MediaCollectionItem>
      createElement() {
    return _CollectionItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemProvider && other.details == details;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, details.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionItemRef
    on AutoDisposeAsyncNotifierProviderRef<MediaCollectionItem> {
  /// The parameter `details` of this provider.
  ContentDetails get details;
}

class _CollectionItemProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CollectionItem,
        MediaCollectionItem> with CollectionItemRef {
  _CollectionItemProviderElement(super.provider);

  @override
  ContentDetails get details => (origin as CollectionItemProvider).details;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
