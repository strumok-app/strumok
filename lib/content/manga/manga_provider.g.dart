// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mangaMediaItemSourcesHash() =>
    r'09cb4d0b2fed9d1952116094473f3d443168f8a7';

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

/// See also [mangaMediaItemSources].
@ProviderFor(mangaMediaItemSources)
const mangaMediaItemSourcesProvider = MangaMediaItemSourcesFamily();

/// See also [mangaMediaItemSources].
class MangaMediaItemSourcesFamily
    extends Family<AsyncValue<List<MangaMediaItemSource>>> {
  /// See also [mangaMediaItemSources].
  const MangaMediaItemSourcesFamily();

  /// See also [mangaMediaItemSources].
  MangaMediaItemSourcesProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return MangaMediaItemSourcesProvider(contentDetails, mediaItems);
  }

  @override
  MangaMediaItemSourcesProvider getProviderOverride(
    covariant MangaMediaItemSourcesProvider provider,
  ) {
    return call(provider.contentDetails, provider.mediaItems);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaMediaItemSourcesProvider';
}

/// See also [mangaMediaItemSources].
class MangaMediaItemSourcesProvider
    extends AutoDisposeFutureProvider<List<MangaMediaItemSource>> {
  /// See also [mangaMediaItemSources].
  MangaMediaItemSourcesProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
        (ref) => mangaMediaItemSources(
          ref as MangaMediaItemSourcesRef,
          contentDetails,
          mediaItems,
        ),
        from: mangaMediaItemSourcesProvider,
        name: r'mangaMediaItemSourcesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mangaMediaItemSourcesHash,
        dependencies: MangaMediaItemSourcesFamily._dependencies,
        allTransitiveDependencies:
            MangaMediaItemSourcesFamily._allTransitiveDependencies,
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      );

  MangaMediaItemSourcesProvider._internal(
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
    FutureOr<List<MangaMediaItemSource>> Function(
      MangaMediaItemSourcesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaMediaItemSourcesProvider._internal(
        (ref) => create(ref as MangaMediaItemSourcesRef),
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
  AutoDisposeFutureProviderElement<List<MangaMediaItemSource>> createElement() {
    return _MangaMediaItemSourcesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaMediaItemSourcesProvider &&
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
mixin MangaMediaItemSourcesRef
    on AutoDisposeFutureProviderRef<List<MangaMediaItemSource>> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _MangaMediaItemSourcesProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaMediaItemSource>>
    with MangaMediaItemSourcesRef {
  _MangaMediaItemSourcesProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as MangaMediaItemSourcesProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as MangaMediaItemSourcesProvider).mediaItems;
}

String _$currentMangaMediaItemSourceHash() =>
    r'ea29156d35c736ee0d4d2b2ace1bf80a139b1dff';

/// See also [currentMangaMediaItemSource].
@ProviderFor(currentMangaMediaItemSource)
const currentMangaMediaItemSourceProvider = CurrentMangaMediaItemSourceFamily();

/// See also [currentMangaMediaItemSource].
class CurrentMangaMediaItemSourceFamily
    extends Family<AsyncValue<MangaMediaItemSource?>> {
  /// See also [currentMangaMediaItemSource].
  const CurrentMangaMediaItemSourceFamily();

  /// See also [currentMangaMediaItemSource].
  CurrentMangaMediaItemSourceProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaMediaItemSourceProvider(contentDetails, mediaItems);
  }

  @override
  CurrentMangaMediaItemSourceProvider getProviderOverride(
    covariant CurrentMangaMediaItemSourceProvider provider,
  ) {
    return call(provider.contentDetails, provider.mediaItems);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentMangaMediaItemSourceProvider';
}

/// See also [currentMangaMediaItemSource].
class CurrentMangaMediaItemSourceProvider
    extends AutoDisposeFutureProvider<MangaMediaItemSource?> {
  /// See also [currentMangaMediaItemSource].
  CurrentMangaMediaItemSourceProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
        (ref) => currentMangaMediaItemSource(
          ref as CurrentMangaMediaItemSourceRef,
          contentDetails,
          mediaItems,
        ),
        from: currentMangaMediaItemSourceProvider,
        name: r'currentMangaMediaItemSourceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$currentMangaMediaItemSourceHash,
        dependencies: CurrentMangaMediaItemSourceFamily._dependencies,
        allTransitiveDependencies:
            CurrentMangaMediaItemSourceFamily._allTransitiveDependencies,
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      );

  CurrentMangaMediaItemSourceProvider._internal(
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
    FutureOr<MangaMediaItemSource?> Function(
      CurrentMangaMediaItemSourceRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaMediaItemSourceProvider._internal(
        (ref) => create(ref as CurrentMangaMediaItemSourceRef),
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
  AutoDisposeFutureProviderElement<MangaMediaItemSource?> createElement() {
    return _CurrentMangaMediaItemSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaMediaItemSourceProvider &&
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
mixin CurrentMangaMediaItemSourceRef
    on AutoDisposeFutureProviderRef<MangaMediaItemSource?> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaMediaItemSourceProviderElement
    extends AutoDisposeFutureProviderElement<MangaMediaItemSource?>
    with CurrentMangaMediaItemSourceRef {
  _CurrentMangaMediaItemSourceProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaMediaItemSourceProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaMediaItemSourceProvider).mediaItems;
}

String _$currentMangaPagesHash() => r'48495d675dfadc4baf4e5bcfdd23c06ddb1341f0';

/// See also [currentMangaPages].
@ProviderFor(currentMangaPages)
const currentMangaPagesProvider = CurrentMangaPagesFamily();

/// See also [currentMangaPages].
class CurrentMangaPagesFamily extends Family<AsyncValue<List<MangaPageInfo>>> {
  /// See also [currentMangaPages].
  const CurrentMangaPagesFamily();

  /// See also [currentMangaPages].
  CurrentMangaPagesProvider call(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) {
    return CurrentMangaPagesProvider(contentDetails, mediaItems);
  }

  @override
  CurrentMangaPagesProvider getProviderOverride(
    covariant CurrentMangaPagesProvider provider,
  ) {
    return call(provider.contentDetails, provider.mediaItems);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentMangaPagesProvider';
}

/// See also [currentMangaPages].
class CurrentMangaPagesProvider
    extends AutoDisposeFutureProvider<List<MangaPageInfo>> {
  /// See also [currentMangaPages].
  CurrentMangaPagesProvider(
    ContentDetails contentDetails,
    List<ContentMediaItem> mediaItems,
  ) : this._internal(
        (ref) => currentMangaPages(
          ref as CurrentMangaPagesRef,
          contentDetails,
          mediaItems,
        ),
        from: currentMangaPagesProvider,
        name: r'currentMangaPagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$currentMangaPagesHash,
        dependencies: CurrentMangaPagesFamily._dependencies,
        allTransitiveDependencies:
            CurrentMangaPagesFamily._allTransitiveDependencies,
        contentDetails: contentDetails,
        mediaItems: mediaItems,
      );

  CurrentMangaPagesProvider._internal(
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
    FutureOr<List<MangaPageInfo>> Function(CurrentMangaPagesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentMangaPagesProvider._internal(
        (ref) => create(ref as CurrentMangaPagesRef),
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
  AutoDisposeFutureProviderElement<List<MangaPageInfo>> createElement() {
    return _CurrentMangaPagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMangaPagesProvider &&
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
mixin CurrentMangaPagesRef
    on AutoDisposeFutureProviderRef<List<MangaPageInfo>> {
  /// The parameter `contentDetails` of this provider.
  ContentDetails get contentDetails;

  /// The parameter `mediaItems` of this provider.
  List<ContentMediaItem> get mediaItems;
}

class _CurrentMangaPagesProviderElement
    extends AutoDisposeFutureProviderElement<List<MangaPageInfo>>
    with CurrentMangaPagesRef {
  _CurrentMangaPagesProviderElement(super.provider);

  @override
  ContentDetails get contentDetails =>
      (origin as CurrentMangaPagesProvider).contentDetails;
  @override
  List<ContentMediaItem> get mediaItems =>
      (origin as CurrentMangaPagesProvider).mediaItems;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
