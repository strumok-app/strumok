// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collectionService)
const collectionServiceProvider = CollectionServiceProvider._();

final class CollectionServiceProvider
    extends
        $FunctionalProvider<
          CollectionService,
          CollectionService,
          CollectionService
        >
    with $Provider<CollectionService> {
  const CollectionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionServiceHash();

  @$internal
  @override
  $ProviderElement<CollectionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollectionService create(Ref ref) {
    return collectionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionService>(value),
    );
  }
}

String _$collectionServiceHash() => r'49687ae478e54466a3021b3ab6e80c7a7e8b19f8';

@ProviderFor(collectionChanges)
const collectionChangesProvider = CollectionChangesProvider._();

final class CollectionChangesProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  const CollectionChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionChangesHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return collectionChanges(ref);
  }
}

String _$collectionChangesHash() => r'0f8683a1d3a68b5c375db0b94fdb336ae790f9bb';

@ProviderFor(CollectionFilterQuery)
const collectionFilterQueryProvider = CollectionFilterQueryProvider._();

final class CollectionFilterQueryProvider
    extends $NotifierProvider<CollectionFilterQuery, String> {
  const CollectionFilterQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionFilterQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionFilterQueryHash();

  @$internal
  @override
  CollectionFilterQuery create() => CollectionFilterQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$collectionFilterQueryHash() =>
    r'16565f9f860fbcc33aeca272cea9d8987dc8e785';

abstract class _$CollectionFilterQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(collectionItems)
const collectionItemsProvider = CollectionItemsProvider._();

final class CollectionItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MediaCollectionItem>>,
          List<MediaCollectionItem>,
          FutureOr<List<MediaCollectionItem>>
        >
    with
        $FutureModifier<List<MediaCollectionItem>>,
        $FutureProvider<List<MediaCollectionItem>> {
  const CollectionItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<MediaCollectionItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MediaCollectionItem>> create(Ref ref) {
    return collectionItems(ref);
  }
}

String _$collectionItemsHash() => r'7f061ed51578f3d6a84966ab98d145a95f417e43';

@ProviderFor(collectionItemsByStatus)
const collectionItemsByStatusProvider = CollectionItemsByStatusProvider._();

final class CollectionItemsByStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>,
          Map<MediaCollectionItemStatus, List<MediaCollectionItem>>,
          FutureOr<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>
        >
    with
        $FutureModifier<
          Map<MediaCollectionItemStatus, List<MediaCollectionItem>>
        >,
        $FutureProvider<
          Map<MediaCollectionItemStatus, List<MediaCollectionItem>>
        > {
  const CollectionItemsByStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionItemsByStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionItemsByStatusHash();

  @$internal
  @override
  $FutureProviderElement<
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>> create(
    Ref ref,
  ) {
    return collectionItemsByStatus(ref);
  }
}

String _$collectionItemsByStatusHash() =>
    r'dc82a46ec5fb8bed38679bd19199935373aea07e';

@ProviderFor(collectionItemsSuppliers)
const collectionItemsSuppliersProvider = CollectionItemsSuppliersProvider._();

final class CollectionItemsSuppliersProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  const CollectionItemsSuppliersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionItemsSuppliersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionItemsSuppliersHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return collectionItemsSuppliers(ref);
  }
}

String _$collectionItemsSuppliersHash() =>
    r'7734ea3459e39c871ec144acafb49a78ad880c00';

@ProviderFor(collectionActiveItems)
const collectionActiveItemsProvider = CollectionActiveItemsProvider._();

final class CollectionActiveItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MediaCollectionItem>>,
          List<MediaCollectionItem>,
          FutureOr<List<MediaCollectionItem>>
        >
    with
        $FutureModifier<List<MediaCollectionItem>>,
        $FutureProvider<List<MediaCollectionItem>> {
  const CollectionActiveItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionActiveItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionActiveItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<MediaCollectionItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MediaCollectionItem>> create(Ref ref) {
    return collectionActiveItems(ref);
  }
}

String _$collectionActiveItemsHash() =>
    r'2ec5e9a6b349760f852d5f61f05a102591b58baa';

@ProviderFor(CollectionFilter)
const collectionFilterProvider = CollectionFilterProvider._();

final class CollectionFilterProvider
    extends $NotifierProvider<CollectionFilter, CollectionFilterModel> {
  const CollectionFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionFilterHash();

  @$internal
  @override
  CollectionFilter create() => CollectionFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionFilterModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionFilterModel>(value),
    );
  }
}

String _$collectionFilterHash() => r'7f607bbc281e55623e6f0dca4b02a846e5549532';

abstract class _$CollectionFilter extends $Notifier<CollectionFilterModel> {
  CollectionFilterModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CollectionFilterModel, CollectionFilterModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CollectionFilterModel, CollectionFilterModel>,
              CollectionFilterModel,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
