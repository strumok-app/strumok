import 'package:strumok/search/search_top_bar/search_suggestion_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_suggestion_provider.g.dart';

@riverpod
class Suggestions extends _$Suggestions {
  @override
  FutureOr<List<SearchSuggestion>> build() {
    return SearchSuggestion.getSuggestions("");
  }

  void suggest(String query) async {
    state = await AsyncValue.guard(
      () => SearchSuggestion.getSuggestions(query),
    );
  }

  void addSuggestion(String query) async {
    await SearchSuggestion.addSuggestion(query);
  }

  void deleteSuggestion(SearchSuggestion suggestion) async {
    state = await AsyncValue.guard(() async {
      await suggestion.delete();

      return state.requireValue
          .where((e) => e.text != suggestion.text)
          .toList();
    });
  }
}
