// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hasCollectionItem)
const hasCollectionItemProvider = HasCollectionItemFamily._();

final class HasCollectionItemProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const HasCollectionItemProvider._({
    required HasCollectionItemFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'hasCollectionItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasCollectionItemHash();

  @override
  String toString() {
    return r'hasCollectionItemProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (String, String);
    return hasCollectionItem(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is HasCollectionItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasCollectionItemHash() => r'cb87bbcc1a4e3853e921c74c29bf26c862efbcd4';

final class HasCollectionItemFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, (String, String)> {
  const HasCollectionItemFamily._()
    : super(
        retry: null,
        name: r'hasCollectionItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HasCollectionItemProvider call(String supplier, String id) =>
      HasCollectionItemProvider._(argument: (supplier, id), from: this);

  @override
  String toString() => r'hasCollectionItemProvider';
}

@ProviderFor(CollectionItem)
const collectionItemProvider = CollectionItemFamily._();

final class CollectionItemProvider
    extends $AsyncNotifierProvider<CollectionItem, MediaCollectionItem> {
  const CollectionItemProvider._({
    required CollectionItemFamily super.from,
    required ContentDetails super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionItemHash();

  @override
  String toString() {
    return r'collectionItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CollectionItem create() => CollectionItem();

  @override
  bool operator ==(Object other) {
    return other is CollectionItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemHash() => r'da30322f1397d61f8aaf08da282584e01b7196f5';

final class CollectionItemFamily extends $Family
    with
        $ClassFamilyOverride<
          CollectionItem,
          AsyncValue<MediaCollectionItem>,
          MediaCollectionItem,
          FutureOr<MediaCollectionItem>,
          ContentDetails
        > {
  const CollectionItemFamily._()
    : super(
        retry: null,
        name: r'collectionItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionItemProvider call(ContentDetails details) =>
      CollectionItemProvider._(argument: details, from: this);

  @override
  String toString() => r'collectionItemProvider';
}

abstract class _$CollectionItem extends $AsyncNotifier<MediaCollectionItem> {
  late final _$args = ref.$arg as ContentDetails;
  ContentDetails get details => _$args;

  FutureOr<MediaCollectionItem> build(ContentDetails details);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<MediaCollectionItem>, MediaCollectionItem>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MediaCollectionItem>, MediaCollectionItem>,
              AsyncValue<MediaCollectionItem>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(collectionItemCurrentItem)
const collectionItemCurrentItemProvider = CollectionItemCurrentItemFamily._();

final class CollectionItemCurrentItemProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const CollectionItemCurrentItemProvider._({
    required CollectionItemCurrentItemFamily super.from,
    required ContentDetails super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemCurrentItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionItemCurrentItemHash();

  @override
  String toString() {
    return r'collectionItemCurrentItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ContentDetails;
    return collectionItemCurrentItem(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentItemProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemCurrentItemHash() =>
    r'88ffc18ea6906207c30f1945dbcd99dc8a0c9bf8';

final class CollectionItemCurrentItemFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, ContentDetails> {
  const CollectionItemCurrentItemFamily._()
    : super(
        retry: null,
        name: r'collectionItemCurrentItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionItemCurrentItemProvider call(ContentDetails contentDetails) =>
      CollectionItemCurrentItemProvider._(argument: contentDetails, from: this);

  @override
  String toString() => r'collectionItemCurrentItemProvider';
}

@ProviderFor(collectionItemCurrentSourceName)
const collectionItemCurrentSourceNameProvider =
    CollectionItemCurrentSourceNameFamily._();

final class CollectionItemCurrentSourceNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const CollectionItemCurrentSourceNameProvider._({
    required CollectionItemCurrentSourceNameFamily super.from,
    required ContentDetails super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemCurrentSourceNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionItemCurrentSourceNameHash();

  @override
  String toString() {
    return r'collectionItemCurrentSourceNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as ContentDetails;
    return collectionItemCurrentSourceName(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentSourceNameProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemCurrentSourceNameHash() =>
    r'a1cba9d382f314ac898e0f6529539acf3ebf676f';

final class CollectionItemCurrentSourceNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, ContentDetails> {
  const CollectionItemCurrentSourceNameFamily._()
    : super(
        retry: null,
        name: r'collectionItemCurrentSourceNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionItemCurrentSourceNameProvider call(ContentDetails contentDetails) =>
      CollectionItemCurrentSourceNameProvider._(
        argument: contentDetails,
        from: this,
      );

  @override
  String toString() => r'collectionItemCurrentSourceNameProvider';
}

@ProviderFor(collectionItemCurrentSubtitleName)
const collectionItemCurrentSubtitleNameProvider =
    CollectionItemCurrentSubtitleNameFamily._();

final class CollectionItemCurrentSubtitleNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const CollectionItemCurrentSubtitleNameProvider._({
    required CollectionItemCurrentSubtitleNameFamily super.from,
    required ContentDetails super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemCurrentSubtitleNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$collectionItemCurrentSubtitleNameHash();

  @override
  String toString() {
    return r'collectionItemCurrentSubtitleNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as ContentDetails;
    return collectionItemCurrentSubtitleName(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentSubtitleNameProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemCurrentSubtitleNameHash() =>
    r'e9ce78a318f07f70488a74ddffce52d10b25e80c';

final class CollectionItemCurrentSubtitleNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, ContentDetails> {
  const CollectionItemCurrentSubtitleNameFamily._()
    : super(
        retry: null,
        name: r'collectionItemCurrentSubtitleNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionItemCurrentSubtitleNameProvider call(
    ContentDetails contentDetails,
  ) => CollectionItemCurrentSubtitleNameProvider._(
    argument: contentDetails,
    from: this,
  );

  @override
  String toString() => r'collectionItemCurrentSubtitleNameProvider';
}

@ProviderFor(collectionItemCurrentPosition)
const collectionItemCurrentPositionProvider =
    CollectionItemCurrentPositionFamily._();

final class CollectionItemCurrentPositionProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const CollectionItemCurrentPositionProvider._({
    required CollectionItemCurrentPositionFamily super.from,
    required ContentDetails super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemCurrentPositionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionItemCurrentPositionHash();

  @override
  String toString() {
    return r'collectionItemCurrentPositionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ContentDetails;
    return collectionItemCurrentPosition(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentPositionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemCurrentPositionHash() =>
    r'421c1745074caea693dd30d55a47bc464e90d0b2';

final class CollectionItemCurrentPositionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, ContentDetails> {
  const CollectionItemCurrentPositionFamily._()
    : super(
        retry: null,
        name: r'collectionItemCurrentPositionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionItemCurrentPositionProvider call(ContentDetails contentDetails) =>
      CollectionItemCurrentPositionProvider._(
        argument: contentDetails,
        from: this,
      );

  @override
  String toString() => r'collectionItemCurrentPositionProvider';
}

@ProviderFor(collectionItemCurrentMediaItemPosition)
const collectionItemCurrentMediaItemPositionProvider =
    CollectionItemCurrentMediaItemPositionFamily._();

final class CollectionItemCurrentMediaItemPositionProvider
    extends
        $FunctionalProvider<
          AsyncValue<MediaItemPosition>,
          MediaItemPosition,
          FutureOr<MediaItemPosition>
        >
    with
        $FutureModifier<MediaItemPosition>,
        $FutureProvider<MediaItemPosition> {
  const CollectionItemCurrentMediaItemPositionProvider._({
    required CollectionItemCurrentMediaItemPositionFamily super.from,
    required ContentDetails super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemCurrentMediaItemPositionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$collectionItemCurrentMediaItemPositionHash();

  @override
  String toString() {
    return r'collectionItemCurrentMediaItemPositionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MediaItemPosition> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MediaItemPosition> create(Ref ref) {
    final argument = this.argument as ContentDetails;
    return collectionItemCurrentMediaItemPosition(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemCurrentMediaItemPositionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemCurrentMediaItemPositionHash() =>
    r'562687c826222e1e3a8a9f156060c04d94778896';

final class CollectionItemCurrentMediaItemPositionFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<MediaItemPosition>, ContentDetails> {
  const CollectionItemCurrentMediaItemPositionFamily._()
    : super(
        retry: null,
        name: r'collectionItemCurrentMediaItemPositionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionItemCurrentMediaItemPositionProvider call(
    ContentDetails contentDetails,
  ) => CollectionItemCurrentMediaItemPositionProvider._(
    argument: contentDetails,
    from: this,
  );

  @override
  String toString() => r'collectionItemCurrentMediaItemPositionProvider';
}
