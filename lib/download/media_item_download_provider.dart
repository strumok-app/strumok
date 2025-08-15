import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/offline_storage.dart';

part 'media_item_download_provider.g.dart';

enum MediaItemDownloadStatus { notStored, stored, downloading }

class MediaItemDownloadState {
  final MediaItemDownloadStatus status;
  final DownloadTask? downloadTask;

  MediaItemDownloadState({required this.status, this.downloadTask});
}

@riverpod
class MediaItemDownload extends _$MediaItemDownload {
  @override
  Future<MediaItemDownloadState> build(
    String supplier,
    String id,
    int number,
  ) async {
    final isStored = await OfflineStorage().sourceExists(supplier, id, number);
    final downloadTask = DownloadManager().getTask(
      getMediaItemDownloadId(supplier, id, number),
    );

    MediaItemDownloadStatus status = MediaItemDownloadStatus.notStored;

    if (downloadTask != null) {
      status = MediaItemDownloadStatus.downloading;

      downloadTask.status.addListener(_onDonwloadStatusChanged);
      ref.onDispose(() {
        downloadTask.status.removeListener(_onDonwloadStatusChanged);
      });
    } else if (isStored) {
      status = MediaItemDownloadStatus.stored;
    }

    return MediaItemDownloadState(status: status, downloadTask: downloadTask);
  }

  void _onDonwloadStatusChanged() {
    final currentState = state.valueOrNull;
    final downloadTask = currentState?.downloadTask;
    if (downloadTask != null && downloadTask.status.value.isCompleted) {
      downloadTask.status.removeListener(_onDonwloadStatusChanged);
      state = AsyncValue.data(
        MediaItemDownloadState(
          status: switch (downloadTask.status.value) {
            DownloadStatus.completed => MediaItemDownloadStatus.stored,
            _ => MediaItemDownloadStatus.notStored,
          },
        ),
      );
    }
  }
}
