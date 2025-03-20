import 'dart:async';

import 'package:sembast/sembast_io.dart';
import 'package:strumok/app_database.dart';
import 'package:strumok/auth/auth.dart' as auth;
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/sync/collection_sync.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:strumok/utils/text.dart';

abstract interface class CollectionRepository {
  Stream<void> get changesStream;
  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id);
  FutureOr<void> save(MediaCollectionItem collectionItem);
  FutureOr<Iterable<MediaCollectionItem>> search({String? query});
  FutureOr<void> delete(String supplier, String id);
}

class LocalCollectionRepository extends CollectionRepository {
  static StoreRef<String, Map<String, Object?>> store = stringMapStoreFactory
      .store("collection");

  final Database db = AppDatabase().db();

  @override
  Stream<void> get changesStream => store.query().onSnapshot(db);

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
          SortOrder("lastSean", false),
        ],
      ),
    );

    return snapshot.map((record) => MediaCollectionItem.fromJson(record.value));
  }

  @override
  FutureOr<void> delete(String supplier, String id) async {
    final itemId = _sanitizeId(supplier, id);

    await db.transaction((tx) => store.record(itemId).delete(tx));
  }
}

class FirebaseRepository extends CollectionRepository {
  final CollectionRepository downstream;
  final auth.User? user;
  late final FirebaseDatabase database;

  FirebaseRepository({required this.downstream, required this.user}) {
    database = FirebaseDatabase(app: Firebase.app());

    if (user != null) {
      CollectionSync.instance.run();
    }
  }

  @override
  Stream<void> get changesStream => downstream.changesStream;

  @override
  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id) {
    return downstream.getCollectionItem(supplier, id);
  }

  @override
  FutureOr<void> save(MediaCollectionItem collectionItem) async {
    _saveToFirebase(collectionItem);
    await downstream.save(collectionItem);
  }

  @override
  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus>? status,
    Set<MediaType>? mediaType,
    Set<String>? suppliersName,
  }) {
    return downstream.search(query: query);
  }

  @override
  FutureOr<void> delete(String supplier, String id) {
    _deleteFromFirebase(supplier, id);
    return downstream.delete(supplier, id);
  }

  Future<void> _saveToFirebase(MediaCollectionItem collectionItem) async {
    if (user == null) {
      return;
    }

    final itemId = _sanitizeId(collectionItem.supplier, collectionItem.id);
    final ref = database.reference().child("collection/${user!.id}/$itemId");

    await ref.set(collectionItem.toJson());
  }

  Future<void> _deleteFromFirebase(String supplier, String id) async {
    if (user == null) {
      return;
    }

    final itemId = _sanitizeId(supplier, id);
    final ref = database.reference().child("collection/${user!.id}/$itemId");

    await ref.remove();
  }
}

String _sanitizeId(String supplier, String id) {
  return supplier + id.replaceAll("/", "|").replaceAll(".", "");
}
