import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class AppSecrets {
  static final AppSecrets _instance = AppSecrets._internal();
  late final Map<String, dynamic> _secrets;

  factory AppSecrets() {
    return _instance;
  }

  AppSecrets._internal();

  Future<void> init() async {
    final secretsContent = await rootBundle.loadString("secrets.json");
    _instance._secrets = await json.decode(secretsContent);
  }

  String getString(String key) {
    return _secrets[key] as String;
  }

  Map<String, dynamic> getJson(String key) {
    return _secrets[key] as Map<String, dynamic>;
  }
}
