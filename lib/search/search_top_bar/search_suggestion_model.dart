import 'package:json_annotation/json_annotation.dart';
import 'package:sembast/sembast_io.dart';
import 'package:strumok/app_database.dart';
import 'package:strumok/utils/text.dart';

part 'search_suggestion_model.g.dart';

@JsonSerializable()
class SearchSuggestion {
  static StoreRef<String, Map<String, Object?>> store = stringMapStoreFactory
      .store("suggestions");

  final String text;
  final DateTime lastSeen;
  final List<String> tokens;

  SearchSuggestion({
    required this.text,
    required this.lastSeen,
    required this.tokens,
  });

  static Future<void> addSuggestion(String query) async {
    final text = cleanupQuery(query);
    final tokens = splitWords(text);

    if (tokens.isEmpty) {
      return;
    }

    final db = AppDatabase().db();

    final exists = await store.record(text).exists(db);
    if (exists) {
      return;
    }

    final suggestion = SearchSuggestion(
      text: text,
      lastSeen: DateTime.now(),
      tokens: tokens,
    );

    await store.record(text).put(db, suggestion.toJson());
  }

  static Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  }) async {
    final text = cleanupQuery(query);
    final db = AppDatabase().db();

    final words = splitWords(text);

    Filter? filter;
    if (words.isNotEmpty) {
      filter = Filter.or(
        words
            .map((w) => Filter.matches("tokens", "^$w", anyInList: true))
            .toList(),
      );
    }

    final snapshot = await store.find(
      db,
      finder: Finder(
        filter: filter,
        sortOrders: [SortOrder("lastSeen", false)],
      ),
    );

    return snapshot.map((it) => SearchSuggestion.fromJson(it.value)).toList();
  }

  static Future<void> deleteOld() async {
    await store.delete(
      AppDatabase().db(),
      finder: Finder(
        filter: Filter.lessThan(
          "lastSean",
          DateTime.now().subtract(Duration(days: 30)),
        ),
      ),
    );
  }

  Future<void> delete() async {
    final db = AppDatabase().db();

    await store.record(text).delete(db);
  }

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$SearchSuggestionToJson(this);
}
