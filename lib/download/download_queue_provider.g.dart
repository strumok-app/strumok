// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DownloadsUpdateStream)
const downloadsUpdateStreamProvider = DownloadsUpdateStreamProvider._();

final class DownloadsUpdateStreamProvider
    extends $StreamNotifierProvider<DownloadsUpdateStream, DownloadTask> {
  const DownloadsUpdateStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadsUpdateStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadsUpdateStreamHash();

  @$internal
  @override
  DownloadsUpdateStream create() => DownloadsUpdateStream();
}

String _$downloadsUpdateStreamHash() =>
    r'9eb3fb78d49656d375cc5ca0376cad4c718935e0';

abstract class _$DownloadsUpdateStream extends $StreamNotifier<DownloadTask> {
  Stream<DownloadTask> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<DownloadTask>, DownloadTask>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DownloadTask>, DownloadTask>,
              AsyncValue<DownloadTask>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(downloadTasks)
const downloadTasksProvider = DownloadTasksProvider._();

final class DownloadTasksProvider
    extends
        $FunctionalProvider<
          List<DownloadTask>,
          List<DownloadTask>,
          List<DownloadTask>
        >
    with $Provider<List<DownloadTask>> {
  const DownloadTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadTasksHash();

  @$internal
  @override
  $ProviderElement<List<DownloadTask>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DownloadTask> create(Ref ref) {
    return downloadTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DownloadTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DownloadTask>>(value),
    );
  }
}

String _$downloadTasksHash() => r'88e6eee94e0796c957855d319f37b00e9f8ae489';
