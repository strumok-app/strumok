// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item_download_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MediaItemDownload)
const mediaItemDownloadProvider = MediaItemDownloadFamily._();

final class MediaItemDownloadProvider
    extends $AsyncNotifierProvider<MediaItemDownload, MediaItemDownloadState> {
  const MediaItemDownloadProvider._({
    required MediaItemDownloadFamily super.from,
    required (String, String, int) super.argument,
  }) : super(
         retry: null,
         name: r'mediaItemDownloadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mediaItemDownloadHash();

  @override
  String toString() {
    return r'mediaItemDownloadProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MediaItemDownload create() => MediaItemDownload();

  @override
  bool operator ==(Object other) {
    return other is MediaItemDownloadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mediaItemDownloadHash() => r'f4ac58802eac64a4fb0cc830068307aeeffddc8a';

final class MediaItemDownloadFamily extends $Family
    with
        $ClassFamilyOverride<
          MediaItemDownload,
          AsyncValue<MediaItemDownloadState>,
          MediaItemDownloadState,
          FutureOr<MediaItemDownloadState>,
          (String, String, int)
        > {
  const MediaItemDownloadFamily._()
    : super(
        retry: null,
        name: r'mediaItemDownloadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MediaItemDownloadProvider call(String supplier, String id, int number) =>
      MediaItemDownloadProvider._(argument: (supplier, id, number), from: this);

  @override
  String toString() => r'mediaItemDownloadProvider';
}

abstract class _$MediaItemDownload
    extends $AsyncNotifier<MediaItemDownloadState> {
  late final _$args = ref.$arg as (String, String, int);
  String get supplier => _$args.$1;
  String get id => _$args.$2;
  int get number => _$args.$3;

  FutureOr<MediaItemDownloadState> build(
    String supplier,
    String id,
    int number,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2, _$args.$3);
    final ref =
        this.ref
            as $Ref<AsyncValue<MediaItemDownloadState>, MediaItemDownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MediaItemDownloadState>,
                MediaItemDownloadState
              >,
              AsyncValue<MediaItemDownloadState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
