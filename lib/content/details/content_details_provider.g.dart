// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(details)
final detailsProvider = DetailsFamily._();

final class DetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContentDetails>,
          ContentDetails,
          FutureOr<ContentDetails>
        >
    with $FutureModifier<ContentDetails>, $FutureProvider<ContentDetails> {
  DetailsProvider._({
    required DetailsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'detailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailsHash();

  @override
  String toString() {
    return r'detailsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ContentDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ContentDetails> create(Ref ref) {
    final argument = this.argument as (String, String);
    return details(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailsHash() => r'2823e9708423ac995a0885c9052c225d823f5f12';

final class DetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ContentDetails>, (String, String)> {
  DetailsFamily._()
    : super(
        retry: null,
        name: r'detailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailsProvider call(String supplier, String id) =>
      DetailsProvider._(argument: (supplier, id), from: this);

  @override
  String toString() => r'detailsProvider';
}

@ProviderFor(detailsAndMedia)
final detailsAndMediaProvider = DetailsAndMediaFamily._();

final class DetailsAndMediaProvider
    extends
        $FunctionalProvider<
          AsyncValue<DetailsAndMediaItems>,
          DetailsAndMediaItems,
          FutureOr<DetailsAndMediaItems>
        >
    with
        $FutureModifier<DetailsAndMediaItems>,
        $FutureProvider<DetailsAndMediaItems> {
  DetailsAndMediaProvider._({
    required DetailsAndMediaFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'detailsAndMediaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailsAndMediaHash();

  @override
  String toString() {
    return r'detailsAndMediaProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DetailsAndMediaItems> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DetailsAndMediaItems> create(Ref ref) {
    final argument = this.argument as (String, String);
    return detailsAndMedia(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailsAndMediaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailsAndMediaHash() => r'0ac36dc6e55c77368b654bf3a33386e64bfb6a1a';

final class DetailsAndMediaFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DetailsAndMediaItems>,
          (String, String)
        > {
  DetailsAndMediaFamily._()
    : super(
        retry: null,
        name: r'detailsAndMediaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailsAndMediaProvider call(String supplier, String id) =>
      DetailsAndMediaProvider._(argument: (supplier, id), from: this);

  @override
  String toString() => r'detailsAndMediaProvider';
}
