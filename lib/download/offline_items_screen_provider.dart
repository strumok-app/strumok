import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/offline_content_models.dart';
import 'package:strumok/download/offline_storage.dart';

part 'offline_items_screen_provider.g.dart';

@riverpod
Future<List<OfflineContentInfo>> offlineContent(Ref ref) async {
  return OfflineStorage().offlineContent();
}
