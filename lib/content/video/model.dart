import 'package:content_suppliers_api/model.dart';

enum OnVideoEndsAction {
  playNext,
  playAgain,
  doNothing,
}

enum StarVideoPosition {
  fromBeginning,
  fromRemembered,
  fromFixedPosition,
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
