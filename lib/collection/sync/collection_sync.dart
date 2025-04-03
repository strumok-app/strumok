import 'dart:async';

import 'package:collection/collection.dart';
import 'package:sembast/sembast_io.dart';
import 'package:strumok/app_database.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/collection/collection_repository.dart';
import 'package:firebase_dart/firebase_dart.dart';
// ignore: implementation_imports
import 'package:firebase_dart/src/database/impl/firebase_impl.dart';
import 'package:strumok/utils/text.dart';

const lastSyncField = "lastSync";
const lastSeenField = "lastSeen";
const positionsField = "positions";

class CollectionSync {
  final StreamController<bool> _syncStatus = StreamController();

  static final CollectionSync instance = CollectionSync._();

  CollectionSync._();

  Stream<bool> get syncStatus => _syncStatus.stream;

  Future<void> run() async {
    // wait for user
    final user = Auth().currentUser;
    if (user == null) {
      return;
    }

    _syncStatus.sink.add(true);

    // obtain databases
    final db = AppDatabase().db();
    final firebase = FirebaseDatabase();

    // read local and remote collection
    final localStore = LocalCollectionRepository.store;
    final ref = firebase.reference().child("collection/${user.id}");

    final lastSyncTimestamp = AppPreferences.lastSyncTimestamp;
    final nowTimestamp = DateTime.timestamp().millisecondsSinceEpoch;
    final remoteSnapshot =
        await ref.orderByChild(lastSeenField).startAt(lastSyncTimestamp).once()
            as DataSnapshotImpl;

    final Map<String, dynamic>? remoteCollection = remoteSnapshot
        .treeStructuredData
        .toJson(true);

    if (remoteCollection == null) {
      _syncStatus.sink.add(false);
      return;
    }

    await db.transaction((tx) async {
      for (final entry in remoteCollection.entries) {
        final key = entry.key;
        final remoteItem = entry.value;
        final localItem = await localStore.record(key).get(tx);

        if (localItem == null) {
          remoteItem["tokens"] = splitWords(remoteItem["title"] ?? "");
          remoteItem[positionsField] = nowTimestamp;

          await localStore.record(key).put(tx, remoteItem);
          continue;
        }

        final int remoteLastSean = remoteItem[lastSeenField] ?? 0;
        final int localLastSean = (localItem[lastSeenField] as int?) ?? 0;

        if (remoteLastSean > localLastSean) {
          final localPositions =
              (localItem[positionsField] as Map<String, dynamic>?) ?? {};
          final remotePositions =
              (remoteItem[positionsField] as Map<String, dynamic>?) ?? {};

          remoteItem[positionsField] = mergeMaps(
            localPositions,
            remotePositions,
            value: (_, v) => v,
          );
          remoteItem[lastSyncField] = nowTimestamp;

          await localStore.record(key).put(tx, remoteItem);
        }
      }

      // cleanup remote deleted
      localStore.delete(
        db,
        finder: Finder(
          filter: Filter.and([
            Filter.notNull(lastSyncField),
            Filter.lessThan(lastSyncField, nowTimestamp),
          ]),
        ),
      );
    });

    AppPreferences.lastSyncTimestamp = nowTimestamp;
    _syncStatus.sink.add(false);
  }
}
