import 'package:content_suppliers_api/model.dart';
import 'package:equatable/equatable.dart';

enum OnVideoEndsAction { playNext, playAgain, doNothing }

enum StarVideoPosition { fromBeginning, fromRemembered, fromFixedPosition }

class SubCacheKey extends Equatable {
  final int itemIdx;
  final String name;

  const SubCacheKey(this.itemIdx, this.name);

  @override
  List<Object?> get props => [itemIdx, name];
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
