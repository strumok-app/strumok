import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/collection/sync/collection_sync.dart';

part 'collection_sync_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<bool> collectionSyncStatus(Ref ref) {
  return CollectionSync.instance.syncStatus;
}