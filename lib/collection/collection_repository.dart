import 'dart:async';

import 'package:collection/collection.dart';
import 'package:sembast/sembast_io.dart';
import 'package:strumok/app_database.dart';
import 'package:strumok/auth/auth.dart' as auth;
import 'package:strumok/collection/collection_item_model.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:strumok/utils/text.dart';

// ignore: implementation_imports
import 'package:firebase_dart/src/database/impl/firebase_impl.dart';

abstract interface class CollectionRepository {
  Stream<int> get changesStream;
  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id);
  FutureOr<void> save(MediaCollectionItem collectionItem);
  FutureOr<Iterable<MediaCollectionItem>> search({String? query});
  FutureOr<void> delete(String supplier, String id);

  void dispose() {}
}

class LocalCollectionRepository extends CollectionRepository {
  static StoreRef<String, Map<String, Object?>> store = stringMapStoreFactory
      .store("collection");

  int _version = 0;
  final Database db = AppDatabase().db();
  final StreamController<int> syncStreamController =
      StreamController.broadcast();

  @override
  Stream<int> get changesStream => syncStreamController.stream;

  @override
  FutureOr<MediaCollectionItem?> getCollectionItem(
    String supplier,
    String id,
  ) async {
    final itemId = _sanitizeId(supplier, id);

    final record = await store.record(itemId).get(db);

    if (record == null) {
      return null;
    }

    return MediaCollectionItem.fromJson(record);
  }

  @override
  Future<void> save(MediaCollectionItem collectionItem) async {
    final itemId = _sanitizeId(collectionItem.supplier, collectionItem.id);
    final recordValue = collectionItem.toJson();

    recordValue["tokens"] = splitWords(collectionItem.title);

    await db.transaction((tx) => store.record(itemId).put(tx, recordValue));

    syncStreamController.add(++_version);
  }

  @override
  FutureOr<Iterable<MediaCollectionItem>> search({String? query}) async {
    final words = query != null ? splitWords(query) : [];

    Filter? filter;
    if (words.isNotEmpty) {
      filter = Filter.or(
        words
            .map((w) => Filter.matches("tokens", "^$w", anyInList: true))
            .toList(),
      );
    }

    final snapshot = await store.find(
      db,
      finder: Finder(
        filter: filter,
        sortOrders: [
          SortOrder("priority", false),
          SortOrder("lastSeen", false),
        ],
      ),
    );

    return snapshot.map((record) => MediaCollectionItem.fromJson(record.value));
  }

  @override
  FutureOr<void> delete(String supplier, String id) async {
    final itemId = _sanitizeId(supplier, id);

    await db.transaction((tx) => store.record(itemId).delete(tx));

    syncStreamController.add(++_version);
  }

  void deleteOlder(Map<String, dynamic> remote) {
    final itemId = _sanitizeId(remote["supplier"], remote["id"]);

    db.transaction((tx) async {
      final localRecord = await store.record(itemId).get(tx);
      final localLastSeen = localRecord?["lastSeen"] as int? ?? 0;
      final remoteLastSeen = remote["lastSeen"] as int? ?? 0;

      if (remoteLastSeen >= localLastSeen) {
        await store.record(itemId).delete(tx);
      }

      if (localRecord != null) {
        syncStreamController.add(++_version);
      }
    });
  }

  void upsertOlder(Map<String, dynamic> remote) {
    final itemId = _sanitizeId(remote["supplier"], remote["id"]);

    db.transaction((tx) async {
      final localRecord = await store.record(itemId).get(tx);
      final localLastSeen = localRecord?["lastSeen"] as int? ?? 0;
      final remoteLastSeen = remote["lastSeen"] as int? ?? 0;

      if (remoteLastSeen > localLastSeen) {
        remote["tokens"] = splitWords(remote["title"]);

        final localPositions =
            (localRecord?["positions"] as Map<String, dynamic>?) ?? {};
        final remotePositions =
            (remote["positions"] as Map<String, dynamic>?) ?? {};

        remote["positions"] = mergeMaps(
          localPositions,
          remotePositions,
          value: (_, v) => v != null && v > 0 ? v : 0,
        );

        await store.record(itemId).put(tx, remote);
      }

      if (localRecord?["status"] != remote["status"]) {
        syncStreamController.add(++_version);
      }
    });
  }
}

class FirebaseRepository extends CollectionRepository {
  final LocalCollectionRepository localRepo;
  final auth.User user;
  late final FirebaseDatabase database;

  final List<StreamSubscription> subs = [];

  FirebaseRepository({required this.localRepo, required this.user}) {
    database = FirebaseDatabase(app: Firebase.app());
  }

  void init() async {
    await database.setPersistenceEnabled(true);

    final userDocRef = database.reference().child("collection/${user.id}");
    await userDocRef.keepSynced(true);

    subs.add(
      userDocRef.onChildAdded.listen(
        (event) => localRepo.upsertOlder(
          (event.snapshot as DataSnapshotImpl).treeStructuredData.toJson(true),
        ),
      ),
    );

    subs.add(
      userDocRef.onChildChanged.listen(
        (event) => localRepo.upsertOlder(
          (event.snapshot as DataSnapshotImpl).treeStructuredData.toJson(true),
        ),
      ),
    );

    subs.add(
      userDocRef.onChildRemoved.listen(
        (event) => localRepo.deleteOlder(event.snapshot.value),
      ),
    );
  }

  @override
  Stream<int> get changesStream => localRepo.changesStream;

  @override
  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id) {
    return localRepo.getCollectionItem(supplier, id);
  }

  @override
  FutureOr<void> save(MediaCollectionItem collectionItem) async {
    _saveToFirebase(collectionItem);
    await localRepo.save(collectionItem);
  }

  @override
  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus>? status,
    Set<MediaType>? mediaType,
    Set<String>? suppliersName,
  }) {
    return localRepo.search(query: query);
  }

  @override
  FutureOr<void> delete(String supplier, String id) {
    _deleteFromFirebase(supplier, id);
    return localRepo.delete(supplier, id);
  }

  Future<void> _saveToFirebase(MediaCollectionItem collectionItem) async {
    final itemId = _sanitizeId(collectionItem.supplier, collectionItem.id);
    final ref = database.reference().child("collection/${user.id}/$itemId");

    await ref.set(collectionItem.toJson());
  }

  Future<void> _deleteFromFirebase(String supplier, String id) async {
    final itemId = _sanitizeId(supplier, id);
    final ref = database.reference().child("collection/${user.id}/$itemId");

    await ref.remove();
  }

  @override
  void dispose() {
    for (var s in subs) {
      s.cancel();
    }
  }
}

String _sanitizeId(String supplier, String id) {
  return supplier + id.replaceAll("/", "|").replaceAll(".", "");
}
