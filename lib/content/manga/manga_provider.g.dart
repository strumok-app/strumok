// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mangaMediaItemSources)
const mangaMediaItemSourcesProvider = MangaMediaItemSourcesFamily._();

final class MangaMediaItemSourcesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MangaMediaItemSource>>,
          List<MangaMediaItemSource>,
          FutureOr<List<MangaMediaItemSource>>
        >
    with
        $FutureModifier<List<MangaMediaItemSource>>,
        $FutureProvider<List<MangaMediaItemSource>> {
  const MangaMediaItemSourcesProvider._({
    required MangaMediaItemSourcesFamily super.from,
    required (ContentDetails, List<ContentMediaItem>) super.argument,
  }) : super(
         retry: null,
         name: r'mangaMediaItemSourcesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mangaMediaItemSourcesHash();

  @override
  String toString() {
    return r'mangaMediaItemSourcesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<MangaMediaItemSource>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MangaMediaItemSource>> create(Ref ref) {
    final argument = this.argument as (ContentDetails, List<ContentMediaItem>);
    return mangaMediaItemSources(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaMediaItemSourcesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaMediaItemSourcesHash() =>
    r'09cb4d0b2fed9d1952116094473f3d443168f8a7';

final class MangaMediaItemSourcesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<MangaMediaItemSource>>,
          (ContentDetails, List<ContentMediaItem>)
        > {
  const MangaMediaItemSourcesFamily._()
    : super(
        retry: null,
        name: r'mangaMediaItemSourcesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MangaMediaItemSourcesProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) => MangaMediaItemSourcesProvider._(
    argument: (contentDetails, mediaItems),
    from: this,
  );

  @override
  String toString() => r'mangaMediaItemSourcesProvider';
}

@ProviderFor(currentMangaMediaItemSource)
const currentMangaMediaItemSourceProvider =
    CurrentMangaMediaItemSourceFamily._();

final class CurrentMangaMediaItemSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<MangaMediaItemSource?>,
          MangaMediaItemSource?,
          FutureOr<MangaMediaItemSource?>
        >
    with
        $FutureModifier<MangaMediaItemSource?>,
        $FutureProvider<MangaMediaItemSource?> {
  const CurrentMangaMediaItemSourceProvider._({
    required CurrentMangaMediaItemSourceFamily super.from,
    required (ContentDetails, List<ContentMediaItem>) super.argument,
  }) : super(
         retry: null,
         name: r'currentMangaMediaItemSourceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentMangaMediaItemSourceHash();

  @override
  String toString() {
    return r'currentMangaMediaItemSourceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<MangaMediaItemSource?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MangaMediaItemSource?> create(Ref ref) {
    final argument = this.argument as (ContentDetails, List<ContentMediaItem>);
    return currentMangaMediaItemSource(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaMediaItemSourceProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentMangaMediaItemSourceHash() =>
    r'ea29156d35c736ee0d4d2b2ace1bf80a139b1dff';

final class CurrentMangaMediaItemSourceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<MangaMediaItemSource?>,
          (ContentDetails, List<ContentMediaItem>)
        > {
  const CurrentMangaMediaItemSourceFamily._()
    : super(
        retry: null,
        name: r'currentMangaMediaItemSourceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentMangaMediaItemSourceProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) => CurrentMangaMediaItemSourceProvider._(
    argument: (contentDetails, mediaItems),
    from: this,
  );

  @override
  String toString() => r'currentMangaMediaItemSourceProvider';
}

@ProviderFor(currentMangaPages)
const currentMangaPagesProvider = CurrentMangaPagesFamily._();

final class CurrentMangaPagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MangaPageInfo>>,
          List<MangaPageInfo>,
          FutureOr<List<MangaPageInfo>>
        >
    with
        $FutureModifier<List<MangaPageInfo>>,
        $FutureProvider<List<MangaPageInfo>> {
  const CurrentMangaPagesProvider._({
    required CurrentMangaPagesFamily super.from,
    required (ContentDetails, List<ContentMediaItem>) super.argument,
  }) : super(
         retry: null,
         name: r'currentMangaPagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentMangaPagesHash();

  @override
  String toString() {
    return r'currentMangaPagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<MangaPageInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MangaPageInfo>> create(Ref ref) {
    final argument = this.argument as (ContentDetails, List<ContentMediaItem>);
    return currentMangaPages(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaPagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentMangaPagesHash() => r'48495d675dfadc4baf4e5bcfdd23c06ddb1341f0';

final class CurrentMangaPagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<MangaPageInfo>>,
          (ContentDetails, List<ContentMediaItem>)
        > {
  const CurrentMangaPagesFamily._()
    : super(
        retry: null,
        name: r'currentMangaPagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentMangaPagesProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) => CurrentMangaPagesProvider._(
    argument: (contentDetails, mediaItems),
    from: this,
  );

  @override
  String toString() => r'currentMangaPagesProvider';
}
