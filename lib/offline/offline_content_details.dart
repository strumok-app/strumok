import 'dart:async';

import 'package:content_suppliers_api/model.dart';

class OfflineContentDetails implements ContentDetails {
  OfflineContentDetails(this._actualDetails);

  final ContentDetails _actualDetails;

  @override
  List<String> get additionalInfo => _actualDetails.additionalInfo;

  @override
  String get description => _actualDetails.description;

  @override
  String get id => _actualDetails.id;

  @override
  String get image => _actualDetails.image;

  @override
  FutureOr<Iterable<ContentMediaItem>> get mediaItems => _actualDetails.mediaItems;

  @override
  MediaType get mediaType => _actualDetails.mediaType;

  @override
  String? get originalTitle => _actualDetails.originalTitle;

  @override
  List<ContentInfo> get similar => _actualDetails.similar;

  @override
  String get supplier => _actualDetails.supplier;

  @override
  String get title => _actualDetails.title;
}
