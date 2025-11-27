// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Suggestions)
const suggestionsProvider = SuggestionsProvider._();

final class SuggestionsProvider
    extends $AsyncNotifierProvider<Suggestions, List<SearchSuggestion>> {
  const SuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestionsHash();

  @$internal
  @override
  Suggestions create() => Suggestions();
}

String _$suggestionsHash() => r'e589e2e6f47ff0d24fd2f7d7b0628d36e4197d0f';

abstract class _$Suggestions extends $AsyncNotifier<List<SearchSuggestion>> {
  FutureOr<List<SearchSuggestion>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<SearchSuggestion>>, List<SearchSuggestion>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SearchSuggestion>>,
                List<SearchSuggestion>
              >,
              AsyncValue<List<SearchSuggestion>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
