import 'dart:async';

import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_repository.dart';
import 'package:content_suppliers_api/model.dart';

class CollectionService {
  final CollectionRepository repository;

  CollectionService({required this.repository});

  Stream<void> get changesStream => repository.changesStream;

  FutureOr<MediaCollectionItem?> getCollectionItem(String supplier, String id) {
    return repository.getCollectionItem(supplier, id);
  }

  FutureOr<MediaCollectionItem> save(MediaCollectionItem collectionItem) async {
    if (collectionItem.status == MediaCollectionItemStatus.none) {
      await repository.delete(collectionItem.supplier, collectionItem.id);
      collectionItem.internalId = null;
      return collectionItem;
    }

    collectionItem.lastSeen = DateTime.now();
    collectionItem.internalId = await repository.save(collectionItem);

    return collectionItem;
  }

  Future<void> delete(String supplier, String id) async {
    await repository.delete(supplier, id);
  }

  FutureOr<Iterable<MediaCollectionItem>> search({
    String? query,
    Set<MediaCollectionItemStatus>? status,
    Set<MediaType>? mediaTypes,
    Set<String>? suppliersNames,
  }) async {
    Iterable<MediaCollectionItem> collectionItems =
        await repository.search(query: query);

    if (status != null) {
      collectionItems = collectionItems.where(
        (i) => status.contains(i.status),
      );
    }

    if (mediaTypes != null) {
      collectionItems = collectionItems.where(
        (i) => mediaTypes.contains(i.mediaType),
      );
    }

    if (suppliersNames != null) {
      collectionItems = collectionItems.where(
        (i) => suppliersNames.contains(i.supplier),
      );
    }

    return collectionItems;
  }
}
