import 'package:strumok/app_database.dart';
import 'package:strumok/utils/text.dart';
import 'package:isar/isar.dart';

part 'search_suggestion_model.g.dart';

@collection
class SearchSuggestion {
  final Id? id;
  final String text;
  final DateTime lastSeen;

  const SearchSuggestion({
    this.id,
    required this.text,
    required this.lastSeen,
  });

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get fts => Isar.splitWords(text);

  static Future<void> addSuggestion(String query) async {
    final text = cleanupQuery(query);

    if (text.isEmpty) {
      return;
    }

    final db = AppDatabase().database;

    var suggestion = await db.searchSuggestions.filter().textEqualTo(text).findFirst();

    suggestion ??= SearchSuggestion(text: text, lastSeen: DateTime.now());

    await db.writeTxn(() async {
      await db.searchSuggestions.put(suggestion!);
    });
  }

  static Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  }) async {
    final text = cleanupQuery(query);
    final db = AppDatabase().database;

    final words = Isar.splitWords(text);

    return db.searchSuggestions
        .where()
        .optional(
          words.isNotEmpty,
          (q) {
            var ftsQ = q.ftsElementStartsWith(words[0]);

            for (var i = 1; i < words.length; i++) {
              ftsQ = ftsQ.or().ftsElementStartsWith(words[i]);
            }

            return ftsQ;
          },
        )
        .sortByLastSeenDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> delete() async {
    final db = AppDatabase().database;

    await db.writeTxn(() async {
      await db.searchSuggestions.delete(id!);
    });
  }
}
