import 'dart:io';

import 'package:sembast/sembast_io.dart';
import 'package:strumok/search/search_top_bar/search_suggestion_model.dart';
import 'package:strumok/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._privateConstructor();
  Database? _db;

  static final AppDatabase _instance = AppDatabase._privateConstructor();

  factory AppDatabase() {
    return _instance;
  }

  Database db() {
    if (_db == null) {
      throw UnsupportedError("Database not initilized!");
    }

    return _db!;
  }

  Future<void> init() async {
    final directory = (await getApplicationSupportDirectory()).path;
    final directoryPath = "$directory${Platform.pathSeparator}database.db";
    _db = await databaseFactoryIo.openDatabase(directoryPath);

    await SearchSuggestion.deleteOld();

    logger.i("Database path: $directory");
  }
}
