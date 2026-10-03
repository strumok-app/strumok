import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';

enum OnVideoEndsAction { playNext, playAgain, doNothing }

enum StartVideoPosition { fromBeginning, fromRemembered, fromFixedPosition }

class SubCacheKey extends Equatable {
  final String supplier;
  final String contentId;
  final int itemIdx;
  final String name;

  const SubCacheKey(this.supplier, this.contentId, this.itemIdx, this.name);

  @override
  List<Object?> get props => [supplier, contentId, itemIdx, name];
}

class SourceSelectorModel {
  final List<ContentMediaItemSource> sources;
  final String? currentSource;
  final String? currentSubtitle;

  SourceSelectorModel({
    required this.sources,
    this.currentSource,
    this.currentSubtitle,
  });
}
