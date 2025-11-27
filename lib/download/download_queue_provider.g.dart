// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(downloadsUpdateStream)
const downloadsUpdateStreamProvider = DownloadsUpdateStreamProvider._();

final class DownloadsUpdateStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DownloadTask>,
          DownloadTask,
          Stream<DownloadTask>
        >
    with $FutureModifier<DownloadTask>, $StreamProvider<DownloadTask> {
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
  $StreamProviderElement<DownloadTask> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DownloadTask> create(Ref ref) {
    return downloadsUpdateStream(ref);
  }
}

String _$downloadsUpdateStreamHash() =>
    r'12147d9bff5ba44469762c95043ace37e8b4fa24';

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
