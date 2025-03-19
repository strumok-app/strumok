import 'package:strumok/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._privateConstructor();

  static final AppDatabase _instance = AppDatabase._privateConstructor();

  factory AppDatabase() {
    return _instance;
  }

  Future<void> init() async {
    final directory = (await getApplicationSupportDirectory()).path;

    logger.i("Database directory: $directory");
  }
}
