import 'package:content_suppliers_api/model.dart';
import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:test/test.dart';

void main() async {
  test('should download hls stream', () async {
    final task = DownloadManager().download(VideoDownloadRequest(
      "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      "test_video.mp4",
      const ContentSearchResult(
        id: "1",
        title: "Test video",
        secondaryTitle: null,
        image: "https://example.com/image.jpg",
        supplier: "Test supplier",
      ),
    ));

    task.progress.addListener(() {
      print("Progress: ${task.progress.value}");
    });

    await task.whenDownloadComplete();
  });
}
