// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_queue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$downloadsUpdateStreamHash() =>
    r'12147d9bff5ba44469762c95043ace37e8b4fa24';

/// See also [downloadsUpdateStream].
@ProviderFor(downloadsUpdateStream)
final downloadsUpdateStreamProvider =
    AutoDisposeStreamProvider<DownloadTask>.internal(
      downloadsUpdateStream,
      name: r'downloadsUpdateStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$downloadsUpdateStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadsUpdateStreamRef = AutoDisposeStreamProviderRef<DownloadTask>;
String _$downloadTasksHash() => r'88e6eee94e0796c957855d319f37b00e9f8ae489';

/// See also [downloadTasks].
@ProviderFor(downloadTasks)
final downloadTasksProvider = AutoDisposeProvider<List<DownloadTask>>.internal(
  downloadTasks,
  name: r'downloadTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadTasksRef = AutoDisposeProviderRef<List<DownloadTask>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
