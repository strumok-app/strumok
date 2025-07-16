// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item_download_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediaItemDownloadHash() => r'f4ac58802eac64a4fb0cc830068307aeeffddc8a';

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

abstract class _$MediaItemDownload
    extends BuildlessAutoDisposeAsyncNotifier<MediaItemDownloadState> {
  late final String supplier;
  late final String id;
  late final int number;

  FutureOr<MediaItemDownloadState> build(
    String supplier,
    String id,
    int number,
  );
}

/// See also [MediaItemDownload].
@ProviderFor(MediaItemDownload)
const mediaItemDownloadProvider = MediaItemDownloadFamily();

/// See also [MediaItemDownload].
class MediaItemDownloadFamily
    extends Family<AsyncValue<MediaItemDownloadState>> {
  /// See also [MediaItemDownload].
  const MediaItemDownloadFamily();

  /// See also [MediaItemDownload].
  MediaItemDownloadProvider call(String supplier, String id, int number) {
    return MediaItemDownloadProvider(supplier, id, number);
  }

  @override
  MediaItemDownloadProvider getProviderOverride(
    covariant MediaItemDownloadProvider provider,
  ) {
    return call(provider.supplier, provider.id, provider.number);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mediaItemDownloadProvider';
}

/// See also [MediaItemDownload].
class MediaItemDownloadProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MediaItemDownload,
          MediaItemDownloadState
        > {
  /// See also [MediaItemDownload].
  MediaItemDownloadProvider(String supplier, String id, int number)
    : this._internal(
        () => MediaItemDownload()
          ..supplier = supplier
          ..id = id
          ..number = number,
        from: mediaItemDownloadProvider,
        name: r'mediaItemDownloadProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mediaItemDownloadHash,
        dependencies: MediaItemDownloadFamily._dependencies,
        allTransitiveDependencies:
            MediaItemDownloadFamily._allTransitiveDependencies,
        supplier: supplier,
        id: id,
        number: number,
      );

  MediaItemDownloadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplier,
    required this.id,
    required this.number,
  }) : super.internal();

  final String supplier;
  final String id;
  final int number;

  @override
  FutureOr<MediaItemDownloadState> runNotifierBuild(
    covariant MediaItemDownload notifier,
  ) {
    return notifier.build(supplier, id, number);
  }

  @override
  Override overrideWith(MediaItemDownload Function() create) {
    return ProviderOverride(
      origin: this,
      override: MediaItemDownloadProvider._internal(
        () => create()
          ..supplier = supplier
          ..id = id
          ..number = number,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplier: supplier,
        id: id,
        number: number,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MediaItemDownload,
    MediaItemDownloadState
  >
  createElement() {
    return _MediaItemDownloadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaItemDownloadProvider &&
        other.supplier == supplier &&
        other.id == id &&
        other.number == number;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplier.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);
    hash = _SystemHash.combine(hash, number.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MediaItemDownloadRef
    on AutoDisposeAsyncNotifierProviderRef<MediaItemDownloadState> {
  /// The parameter `supplier` of this provider.
  String get supplier;

  /// The parameter `id` of this provider.
  String get id;

  /// The parameter `number` of this provider.
  int get number;
}

class _MediaItemDownloadProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MediaItemDownload,
          MediaItemDownloadState
        >
    with MediaItemDownloadRef {
  _MediaItemDownloadProviderElement(super.provider);

  @override
  String get supplier => (origin as MediaItemDownloadProvider).supplier;
  @override
  String get id => (origin as MediaItemDownloadProvider).id;
  @override
  int get number => (origin as MediaItemDownloadProvider).number;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
