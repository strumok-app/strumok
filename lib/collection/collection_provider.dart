import 'package:strumok/auth/auth_provider.dart';
import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_repository.dart';
import 'package:strumok/collection/collection_service.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:strumok/settings/settings_provider.dart';
import 'package:strumok/utils/collections.dart';
import 'package:collection/collection.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_provider.g.dart';

@immutable
class CollectionState {
  final String? query;
  final Map<MediaCollectionItemStatus, List<MediaCollectionItem>> groups;
  final Set<MediaCollectionItemStatus> status;

  const CollectionState({
    this.query,
    required this.groups,
    required this.status,
  });

  static const empty = CollectionState(groups: {}, status: {});

  CollectionState copyWith({
    String? query,
    Map<MediaCollectionItemStatus, List<MediaCollectionItem>>? groups,
    Set<MediaCollectionItemStatus>? status,
  }) {
    return CollectionState(
      query: query ?? this.query,
      groups: groups ?? this.groups,
      status: status ?? this.status,
    );
  }
}

@Riverpod(keepAlive: true)
CollectionService collectionService(Ref ref) {
  final user = ref.watch(userProvider).valueOrNull;
  final offlineMode = ref.read(offlineModeProvider);

  final localRepository = LocalCollectionRepository();
  CollectionRepository repository = localRepository;

  if (!offlineMode && user != null) {
    final remoteRepository = FirebaseRepository(
      localRepo: localRepository,
      user: user,
    );
    remoteRepository.init();

    repository = remoteRepository;
  }

  ref.onDispose(() => repository.dispose);

  return CollectionService(repository: repository);
}

@Riverpod(keepAlive: true)
class CollectionChanges extends _$CollectionChanges {
  @override
  Stream<void> build() {
    return ref.watch(collectionServiceProvider).changesStream;
  }
}

final collectionFilterQueryProvider = StateProvider<String>((ref) => "");

@riverpod
Future<List<MediaCollectionItem>> collectionItems(Ref ref) async {
  ref.watch(collectionChangesProvider);

  final repository = ref.watch(collectionServiceProvider);
  // ignore: avoid_manual_providers_as_generated_provider_dependency
  final query = ref.watch(collectionFilterQueryProvider);
  final collectionFilter = ref.watch(collectionFilterProvider);

  final collectionItems = await repository.search(
    query: query,
    status: collectionFilter.status,
    mediaTypes: collectionFilter.mediaTypes,
    suppliersNames: collectionFilter.suppliersNames,
  );

  return collectionItems.toList();
}

@riverpod
Future<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>
collectionItemsByStatus(Ref ref) async {
  final collectionItems = await ref.watch(collectionItemsProvider.future);

  return Future.value(collectionItems.groupListsBy((e) => e.status));
}

@riverpod
Future<Set<String>> collectionItemsSuppliers(Ref ref) async {
  ref.watch(collectionChangesProvider);

  final repository = ref.watch(collectionServiceProvider);
  final collectionItems = await repository.search();

  return collectionItems
      .map((item) => item.supplier)
      .toSet()
      .intersection(ContentSuppliers().suppliersName);
}

@riverpod
Future<Map<MediaCollectionItemStatus, List<MediaCollectionItem>>>
collectionActiveItems(Ref ref) async {
  ref.watch(collectionChangesProvider);

  final repository = ref.watch(collectionServiceProvider);

  final collectionItems = await repository.search(
    status: {
      MediaCollectionItemStatus.inProgress,
      MediaCollectionItemStatus.latter,
    },
  );

  final activeItems = collectionItems.groupListsBy((e) => e.status);

  return activeItems;
}

@immutable
class CollectionFilterModel extends Equatable {
  final Set<MediaCollectionItemStatus> status;
  final Set<MediaType> mediaTypes;
  final Set<String> suppliersNames;

  const CollectionFilterModel({
    required this.status,
    required this.mediaTypes,
    required this.suppliersNames,
  });

  @override
  List<Object?> get props => [status, mediaTypes, suppliersNames];

  CollectionFilterModel copyWith({
    Set<MediaCollectionItemStatus>? status,
    Set<MediaType>? mediaTypes,
    Set<String>? suppliersNames,
  }) {
    return CollectionFilterModel(
      status: status ?? this.status,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      suppliersNames: suppliersNames ?? this.suppliersNames,
    );
  }
}

@riverpod
class CollectionFilter extends _$CollectionFilter {
  @override
  CollectionFilterModel build() {
    return CollectionFilterModel(
      status: MediaCollectionItemStatus.values.toSet(),
      mediaTypes: MediaType.values.toSet(),
      suppliersNames: ContentSuppliers().suppliersName,
    );
  }

  void toggleStatus(MediaCollectionItemStatus status) {
    final newStatus = state.status.toggle(status);
    state = state.copyWith(status: newStatus);
  }

  void toggleMediaType(MediaType mediaType) {
    final newMediaTypes = state.mediaTypes.toggle(mediaType);
    state = state.copyWith(mediaTypes: newMediaTypes);
  }

  void toggleSupplierName(String supplierName) {
    final newSupplierNames = state.suppliersNames.toggle(supplierName);
    state = state.copyWith(suppliersNames: newSupplierNames);
  }

  void toggleAllSuppliers(bool select) {
    final newSupplierNames =
        select ? ContentSuppliers().suppliersName : <String>{};
    state = state.copyWith(suppliersNames: newSupplierNames);
  }
}
