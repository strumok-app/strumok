import 'dart:io';

import 'package:strumok/app_secrets.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:path_provider/path_provider.dart';

class AppInitFirebase {
  AppInitFirebase._privateConstructor();

  static final AppInitFirebase _instance =
      AppInitFirebase._privateConstructor();

  factory AppInitFirebase() {
    return _instance;
  }

  Future<FirebaseOptions> loadOptions() async {
    final firebaseOptionsJson = AppSecrets().getJson("firebase");
    return FirebaseOptions.fromMap(
      firebaseOptionsJson,
    );
  }

  Future<FirebaseApp> init({
    isolated = true,
    FirebaseOptions? options,
  }) async {
    final directory =
        "${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}firebase";

    FirebaseDart.setup(storagePath: directory, isolated: isolated);

    return await Firebase.initializeApp(
      options: options ?? await loadOptions(),
    );
  }
}
