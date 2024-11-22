class DownloadState {
  final bool downloading;
  final double progress;
  final String? error;

  DownloadState({
    required this.downloading,
    required this.progress,
    this.error,
  });

  factory DownloadState.create() => DownloadState(
        downloading: false,
        progress: 0.0,
      );

  DownloadState updateProgress(double progress) {
    return DownloadState(
      downloading: downloading,
      progress: progress,
    );
  }

  DownloadState start() {
    return DownloadState(
      downloading: true,
      progress: 0.0,
    );
  }

  DownloadState fail(String error) {
    return DownloadState(
      downloading: downloading,
      progress: progress,
      error: error,
    );
  }

  DownloadState done() {
    return DownloadState(
      downloading: false,
      progress: 1.0,
    );
  }
}
