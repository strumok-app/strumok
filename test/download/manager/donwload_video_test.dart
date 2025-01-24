import 'package:strumok/download/manager/manager.dart';
import 'package:strumok/download/manager/models.dart';
import 'package:test/test.dart';

void main() async {
  test('should download hls stream', () async {
    final task = DownloadManager().download(VideoDownloadRequest(
      "https://vwyn3lxe5fv5.premilkyway.com/hls2/01/00507/vhtb766tmr5r_h/master.m3u8?t=A6lLhqCixTNKFNZHs-HPtEy-bPl4YlXxy57cp9reU2E&s=1737637952&e=129600&f=14756349&srv=m2q5ea5w42hk&i=0.4&sp=500&p1=m2q5ea5w42hk&p2=m2q5ea5w42hk&asn=34867",
      "test_video.mp4",
    ));

    task.progress.addListener(() {
      print("Progress: ${task.progress.value}");
    });

    await task.whenDownloadComplete();
  });
}
