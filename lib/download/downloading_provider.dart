import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/manager/models.dart';

part 'downloading_provider.g.dart';

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
