import 'package:strumok/collection/collection_item_model.dart';
import 'package:strumok/collection/collection_provider.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_item_provider.g.dart';

@riverpod
Future<bool> hasCollectionItem(Ref ref, String supplier, String id) async {
  final service = ref.read(collectionServiceProvider);
  final item = await service.getCollectionItem(supplier, id);

  return item != null;
}

@riverpod
class CollectionItem extends _$CollectionItem {
  @override
  FutureOr<MediaCollectionItem> build(ContentDetails details) async {
    final service = ref.read(collectionServiceProvider);
    final item = await service.getCollectionItem(details.supplier, details.id);

    return item?.copyWith(title: details.title, image: details.image) ??
        MediaCollectionItem.fromContentDetails(details);
  }

  void setCurrentItem(int itemIdx) async {
    final value = state.requireValue;
    final newValue = value.copyWith(currentItem: itemIdx);

    _setNewState(newValue);
  }

  void setCurrentSource(String? sourceName) async {
    final value = state.requireValue;
    final newValue = value.copyWith(currentSourceName: () => sourceName);

    _setNewState(newValue);
  }

  void setCurrentSubtitle(String? subtitleName) async {
    final value = state.requireValue;
    final newValue = value.copyWith(currentSubtitleName: () => subtitleName);

    _setNewState(newValue);
  }

  void setCurrentPosition(int position, [int? length]) async {
    if (position < 0) {
      throw ArgumentError("position cant be negative: $position");
    }

    if (length != null && length <= 0) {
      return;
    }

    final value = state.requireValue;
    final currentItemPosition = value.currentMediaItemPosition;

    if (value.mediaType == MediaType.video) {
      if (position > 10 &&
          (currentItemPosition.position - position).abs() > 10) {
        final newValue = value.copyWith(
          positions: {
            ...value.positions,
            value.currentItem: currentItemPosition.copyWith(
              position: position,
              length: length,
            ),
          },
          status: MediaCollectionItemStatus.inProgress,
        );

        _setNewState(newValue);
      }
    } else {
      if (position == value.currentPosition) {
        return;
      }

      final newValue = value.copyWith(
        positions: {
          ...value.positions,
          value.currentItem: currentItemPosition.copyWith(
            position: position,
            length: length,
          ),
        },
        status: MediaCollectionItemStatus.inProgress,
      );

      _setNewState(newValue);
    }
  }

  void setCurrentLength(int length) async {
    final value = state.requireValue;
    final currentItemPosition = value.currentMediaItemPosition;

    if (length <= 0) {
      return;
    }

    final newValue = value.copyWith(
      positions: {
        ...value.positions,
        value.currentItem: currentItemPosition.copyWith(
          length: length,
          position: currentItemPosition.position >= length
              ? length - 1
              : currentItemPosition.position,
        ),
      },
      status: MediaCollectionItemStatus.inProgress,
    );

    _setNewState(newValue);
  }

  void setStatus(MediaCollectionItemStatus status) async {
    final value = state.requireValue;
    final newValue = value.copyWith(status: status);

    _setNewState(newValue);
  }

  void setPriority(int priority) async {
    final value = state.requireValue;

    if (value.status != MediaCollectionItemStatus.none) {
      final newValue = value.copyWith(priority: priority);

      _setNewState(newValue);
    }
  }

  void _setNewState(MediaCollectionItem newValue) async {
    final newState = await AsyncValue.guard(() => _saveNewValue(newValue));
    if (ref.mounted) {
      state = newState;
    }
  }

  Future<MediaCollectionItem> _saveNewValue(
    MediaCollectionItem newValue,
  ) async {
    final service = ref.read(collectionServiceProvider);

    await service.save(newValue);

    return newValue;
  }
}

@riverpod
Future<int> collectionItemCurrentItem(Ref ref, ContentDetails contentDetails) {
  return ref.watch(
    collectionItemProvider(
      contentDetails,
    ).selectAsync((value) => value.currentItem),
  );
}

@riverpod
Future<String?> collectionItemCurrentSourceName(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(
    collectionItemProvider(
      contentDetails,
    ).selectAsync((value) => value.currentSourceName),
  );
}

@riverpod
Future<String?> collectionItemCurrentSubtitleName(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(
    collectionItemProvider(
      contentDetails,
    ).selectAsync((value) => value.currentSubtitleName),
  );
}

@riverpod
Future<int> collectionItemCurrentPosition(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(
    collectionItemProvider(
      contentDetails,
    ).selectAsync((value) => value.currentPosition),
  );
}

@riverpod
Future<MediaItemPosition> collectionItemCurrentMediaItemPosition(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(
    collectionItemProvider(
      contentDetails,
    ).selectAsync((value) => value.currentMediaItemPosition),
  );
}
