import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/manager/manager.dart';

part 'download_queue_provider.g.dart';

@riverpod
class DownloadsUpdateStream extends _$DownloadsUpdateStream {
  @override
  Stream<DownloadTask> build() => DownloadManager().downloadsUpdate;

  @override
  bool updateShouldNotify(
    AsyncValue<DownloadTask> previous,
    AsyncValue<DownloadTask> next,
  ) {
    return true;
  }
}

@riverpod
List<DownloadTask> downloadTasks(Ref ref) {
  ref.watch(downloadsUpdateStreamProvider);
  return DownloadManager().getDownloadTasksOfType({
    DownloadType.video,
    DownloadType.manga,
  });
}
