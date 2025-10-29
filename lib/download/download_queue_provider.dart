import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/manager/manager.dart';

part 'download_queue_provider.g.dart';

@riverpod
Stream<DownloadTask> downloadsUpdateStream(Ref ref) {
  return DownloadManager().downloadsUpdate;
}

@riverpod
List<DownloadTask> downloadTasks(Ref ref) {
  ref.watch(downloadsUpdateStreamProvider);
  return DownloadManager().getDownloadTasksOfType({
    DownloadType.video,
    DownloadType.manga,
  });
}
