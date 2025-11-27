// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_items_screen_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offlineContent)
const offlineContentProvider = OfflineContentProvider._();

final class OfflineContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OfflineContentInfo>>,
          List<OfflineContentInfo>,
          FutureOr<List<OfflineContentInfo>>
        >
    with
        $FutureModifier<List<OfflineContentInfo>>,
        $FutureProvider<List<OfflineContentInfo>> {
  const OfflineContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offlineContentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offlineContentHash();

  @$internal
  @override
  $FutureProviderElement<List<OfflineContentInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OfflineContentInfo>> create(Ref ref) {
    return offlineContent(ref);
  }
}

String _$offlineContentHash() => r'da5407569508efe9ffbbdb98ada3718ccd265d5b';
