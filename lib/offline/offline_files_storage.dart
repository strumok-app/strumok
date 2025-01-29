import 'package:content_suppliers_api/model.dart';

class OfflineFilesStorage {
  static final OfflineFilesStorage _instance = OfflineFilesStorage._internal();

  factory OfflineFilesStorage() {
    return _instance;
  }

  OfflineFilesStorage._internal();

  String getMediaItemSourcePath(
    ContentDetails details,
    ContentMediaItem mediaItem,
    ContentMediaItemSource source,
  ) {
    return "";
  }
}
