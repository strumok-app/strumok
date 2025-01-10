import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    final item = await service.getCollectionItem(
      details.supplier,
      details.id,
    );

    return item?.copyWith(title: details.title, image: details.image) ??
        MediaCollectionItem.fromContentDetails(details);
  }

  void setCurrentItem(int itemIdx) async {
    final value = state.requireValue;
    final newValue = value.copyWith(currentItem: itemIdx);

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setCurrentSource(String? sourceName) async {
    final value = state.requireValue;
    final newValue = value.copyWith(currentSourceName: () => sourceName);

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setCurrentSubtitle(String? subtitleName) async {
    final value = state.requireValue;
    final newValue = value.copyWith(currentSubtitleName: () => subtitleName);

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setCurrentPosition(int position, [int? length]) async {
    final value = state.requireValue;
    final currentItemPosition = value.currentMediaItemPosition;

    if (value.mediaType == MediaType.video) {
      if ((currentItemPosition.position - position).abs() > 10) {
        final newValue = value.copyWith(
          positions: {
            value.currentItem: currentItemPosition.copyWith(
              position: position,
              length: length,
            ),
          },
          status: MediaCollectionItemStatus.inProgress,
        );

        state = await AsyncValue.guard(() => _saveNewValue(newValue));
      }
    } else {
      if (position == value.currentPosition) {
        return;
      }

      final newValue = value.copyWith(
        positions: {
          value.currentItem: currentItemPosition.copyWith(
            position: position,
            length: length,
          ),
        },
        status: MediaCollectionItemStatus.inProgress,
      );

      state = await AsyncValue.guard(() => _saveNewValue(newValue));
    }
  }

  void setCurrentLength(int length) async {
    final value = state.requireValue;
    final currentItemPosition = value.currentMediaItemPosition;

    final newValue = value.copyWith(
      positions: {
        value.currentItem: currentItemPosition.copyWith(
          length: length,
          position: currentItemPosition.position >= length ? 0 : null,
        ),
      },
      status: MediaCollectionItemStatus.inProgress,
    );

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setStatus(MediaCollectionItemStatus status) async {
    final value = state.requireValue;
    final newValue = value.copyWith(status: status);

    state = await AsyncValue.guard(() => _saveNewValue(newValue));
  }

  void setPriority(int priority) async {
    final value = state.requireValue;

    if (value.status != MediaCollectionItemStatus.none) {
      final newValue = value.copyWith(priority: priority);

      state = await AsyncValue.guard(() => _saveNewValue(newValue));
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
Future<int> collectionItemCurrentItem(
  Ref ref,
  ContentDetails contentDetails,
) {
  return ref.watch(collectionItemProvider(contentDetails).selectAsync((value) => value.currentItem));
}

@riverpod
Future<String?> collectionItemCurrentSourceName(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(collectionItemProvider(contentDetails).selectAsync((value) => value.currentSourceName));
}

@riverpod
Future<String?> collectionItemCurrentSubtitleName(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(collectionItemProvider(contentDetails).selectAsync((value) => value.currentSubtitleName));
}

@riverpod
Future<int> collectionItemCurrentPosition(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(collectionItemProvider(contentDetails).selectAsync((value) => value.currentPosition));
}

@riverpod
Future<MediaItemPosition> collectionItemCurrentMediaItemPosition(
  Ref ref,
  ContentDetails contentDetails,
) async {
  return ref.watch(collectionItemProvider(contentDetails).selectAsync((value) => value.currentMediaItemPosition));
}
