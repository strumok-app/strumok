import 'dart:async';

import 'package:strumok/app_database.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/auth/auth.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_repository.dart';
import 'package:firebase_dart/firebase_dart.dart';
// ignore: implementation_imports
import 'package:firebase_dart/src/database/impl/firebase_impl.dart';

class CollectionSync {
  final StreamController<bool> _syncStatus = StreamController();

  static final CollectionSync instance = CollectionSync._();

  CollectionSync._();

  Stream<bool> get syncStatus => _syncStatus.stream;

  Future<void> run() async {
    // wait for user
    final user = Auth.instance.currentUser;
    if (user == null) {
      return;
    }

    _syncStatus.sink.add(true);

    // obtain databases
    final isar = AppDatabase.database();
    final firebase = FirebaseDatabase();

    // read local and remote collection
    final localCollection = isar.isarMediaCollectionItems;
    final ref = firebase.reference().child("collection/${user.id}");

    final lastSyncTimestamp = AppPreferences.lastSyncTimestamp;
    final nowTimestamp = DateTime.timestamp().millisecondsSinceEpoch;
    final remoteSnapshot = await ref
        .orderByChild("lastSeen")
        .startAt(lastSyncTimestamp)
        .once() as DataSnapshotImpl;

    final remoteCollection = remoteSnapshot.treeStructuredData.toJson(true);

    if (remoteCollection == null) {
      _syncStatus.sink.add(false);
      return;
    }

    await isar.writeTxn(() async {
      // iterate remote items
      for (final remoteItemJson in remoteCollection.values) {
        var remoteItem = MediaCollectionItem.fromJson(remoteItemJson);
        final localItem = await localCollection.getBySupplierId(
          remoteItem.supplier,
          remoteItem.id,
        );

        // store newer remote items
        if (localItem == null ||
            remoteItem.lastSeen!.isAfter(localItem.lastSeen!)) {
          if (localItem != null) {
            // set local internalId
            remoteItem.internalId = localItem.isarId;
            // merge positions
            _mergePositions(remoteItem, localItem);
          }

          var isarMediaCollectionItem =
              IsarMediaCollectionItem.fromMediaCollectionItem(remoteItem);

          await localCollection.put(
            isarMediaCollectionItem,
          );
        }
      }
    });

    AppPreferences.lastSyncTimestamp = nowTimestamp;
    _syncStatus.sink.add(false);
  }

  static void _mergePositions(
    MediaCollectionItem remoteItem,
    IsarMediaCollectionItem localItem,
  ) {
    final positions = {...remoteItem.positions};
    if (localItem.positions != null) {
      for (final localPosition in localItem.positions!) {
        if (!remoteItem.positions.containsKey(localPosition.number)) {
          positions[localPosition.number] = MediaItemPosition(
            position: localPosition.position,
            length: localPosition.length,
          );
        }
      }
    }
    remoteItem.positions = positions;
  }
}
