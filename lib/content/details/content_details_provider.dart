import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strumok/content_suppliers/content_suppliers.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/download/models.dart';
import 'package:strumok/download/offline_storage.dart';
import 'package:strumok/settings/settings_provider.dart';

part 'content_details_provider.g.dart';

@riverpod
Future<ContentDetails> details(Ref ref, String supplier, String id) async {
  final offlineMode = ref.watch(offlineModeProvider);
  final langs = ref.watch(contentLanguageSettingsProvider);
  final link = ref.keepAlive();

  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 5), () {
      link.close();
    });
  });

  ref.onResume(() {
    timer?.cancel();
  });

  if (offlineMode) {
    return OfflineStorage().getContentDetails(supplier, id);
  }

  final details = await ContentSuppliers()
      .detailsById(supplier, id, langs)
      .then((d) => ContentDetailsWithOffline(d) as ContentDetails)
      .timeout(
        Duration(seconds: 30),
        onTimeout: () async => OfflineStorage().getContentDetails(supplier, id),
      );

  return details;
}

class DetailsAndMediaItems {
  final ContentDetails contentDetails;
  final List<ContentMediaItem> mediaItems;

  DetailsAndMediaItems(this.contentDetails, this.mediaItems);
}

@riverpod
Future<DetailsAndMediaItems> detailsAndMedia(
  Ref ref,
  String supplier,
  String id,
) async {
  final contentDetails = await ref.read(detailsProvider(supplier, id).future);
  final mediaItems = await contentDetails.mediaItems;

  return DetailsAndMediaItems(contentDetails, mediaItems.toList());
}
