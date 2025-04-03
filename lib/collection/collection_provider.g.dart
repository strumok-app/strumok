// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionServiceHash() => r'212f40e1715e296385798b99e1c938486fab321d';

/// See also [collectionService].
@ProviderFor(collectionService)
final collectionServiceProvider = Provider<CollectionService>.internal(
  collectionService,
  name: r'collectionServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collectionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionServiceRef = ProviderRef<CollectionService>;
String _$collectionItemsHash() => r'7f061ed51578f3d6a84966ab98d145a95f417e43';

/// See also [collectionItems].
@ProviderFor(collectionItems)
final collectionItemsProvider =
    AutoDisposeFutureProvider<List<MediaCollectionItem>>.internal(
      collectionItems,
      name: r'collectionItemsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$collectionItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionItemsRef =
    AutoDisposeFutureProviderRef<List<MediaCollectionItem>>;
String _$collectionItemsByStatusHash() =>
    r'dc82a46ec5fb8bed38679bd19199935373aea07e';

/// See also [collectionItemsByStatus].
@ProviderFor(collectionItemsByStatus)
final collectionItemsByStatusProvider = AutoDisposeFutureProvider<
  Map<MediaCollectionItemStatus, List<MediaCollectionItem>>
>.internal(
  collectionItemsByStatus,
  name: r'collectionItemsByStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collectionItemsByStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionItemsByStatusRef =
    AutoDisposeFutureProviderRef<
      Map<MediaCollectionItemStatus, List<MediaCollectionItem>>
    >;
String _$collectionItemsSuppliersHash() =>
    r'7734ea3459e39c871ec144acafb49a78ad880c00';

/// See also [collectionItemsSuppliers].
@ProviderFor(collectionItemsSuppliers)
final collectionItemsSuppliersProvider =
    AutoDisposeFutureProvider<Set<String>>.internal(
      collectionItemsSuppliers,
      name: r'collectionItemsSuppliersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$collectionItemsSuppliersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionItemsSuppliersRef = AutoDisposeFutureProviderRef<Set<String>>;
String _$collectionActiveItemsHash() =>
    r'3bb2056ae84300d6fc2cd2d42c7d072b504eb523';

/// See also [collectionActiveItems].
@ProviderFor(collectionActiveItems)
final collectionActiveItemsProvider = AutoDisposeFutureProvider<
  Map<MediaCollectionItemStatus, List<MediaCollectionItem>>
>.internal(
  collectionActiveItems,
  name: r'collectionActiveItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collectionActiveItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionActiveItemsRef =
    AutoDisposeFutureProviderRef<
      Map<MediaCollectionItemStatus, List<MediaCollectionItem>>
    >;
String _$collectionChangesHash() => r'9cdbf00aee59ae6661f58a392677e0a6aa07d663';

/// See also [CollectionChanges].
@ProviderFor(CollectionChanges)
final collectionChangesProvider =
    StreamNotifierProvider<CollectionChanges, void>.internal(
      CollectionChanges.new,
      name: r'collectionChangesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$collectionChangesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CollectionChanges = StreamNotifier<void>;
String _$collectionFilterHash() => r'7f607bbc281e55623e6f0dca4b02a846e5549532';

/// See also [CollectionFilter].
@ProviderFor(CollectionFilter)
final collectionFilterProvider = AutoDisposeNotifierProvider<
  CollectionFilter,
  CollectionFilterModel
>.internal(
  CollectionFilter.new,
  name: r'collectionFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collectionFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionFilter = AutoDisposeNotifier<CollectionFilterModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
