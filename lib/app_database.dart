import 'package:strumok/collection/collection_repository.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_model.dart';
import 'package:strumok/utils/logger.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._privateConstructor();

  static final AppDatabase _instance = AppDatabase._privateConstructor();

  factory AppDatabase() {
    return _instance;
  }

  late Isar _isar;

  Future<void> init() async {
    final directory = (await getApplicationSupportDirectory()).path;

    logger.i("Database directory: $directory");

    _isar = await Isar.open(
      [SearchSuggestionSchema, IsarMediaCollectionItemSchema],
      directory: directory,
    );
  }

  Isar get database {
    return _isar;
  }
}
