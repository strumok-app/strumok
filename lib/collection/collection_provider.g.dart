// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$collectionServiceHash() => r'903f958ae1c771553d27ee159089b670a27e5d67';

/// See also [collectionService].
@ProviderFor(collectionService)
final collectionServiceProvider = Provider<CollectionService>.internal(
  collectionService,
  name: r'collectionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionServiceRef = ProviderRef<CollectionService>;
String _$collectionHash() => r'ac1e7e9d35f6867fb1c5bd8e4216b17b5746e6c7';

/// See also [collection].
@ProviderFor(collection)
final collectionProvider = AutoDisposeFutureProvider<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>.internal(
  collection,
  name: r'collectionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$collectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionRef = AutoDisposeFutureProviderRef<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>;
String _$collectionActiveItemsHash() =>
    r'023443907a6e42d251d4484fee05ce67a67fe3c4';

/// See also [collectionActiveItems].
@ProviderFor(collectionActiveItems)
final collectionActiveItemsProvider = AutoDisposeFutureProvider<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>.internal(
  collectionActiveItems,
  name: r'collectionActiveItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionActiveItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionActiveItemsRef = AutoDisposeFutureProviderRef<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>;
String _$collectionChangesHash() => r'9cdbf00aee59ae6661f58a392677e0a6aa07d663';

/// See also [CollectionChanges].
@ProviderFor(CollectionChanges)
final collectionChangesProvider =
    StreamNotifierProvider<CollectionChanges, void>.internal(
  CollectionChanges.new,
  name: r'collectionChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionChanges = StreamNotifier<void>;
String _$collectionFilterHash() => r'bc8cf7307bfca96d2b8e0c351da1460ad703e6a0';

/// See also [CollectionFilter].
@ProviderFor(CollectionFilter)
final collectionFilterProvider = AutoDisposeNotifierProvider<CollectionFilter,
    CollectionFilterModel>.internal(
  CollectionFilter.new,
  name: r'collectionFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$collectionFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CollectionFilter = AutoDisposeNotifier<CollectionFilterModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
