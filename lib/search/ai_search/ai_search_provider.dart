import 'package:googleai_dart/googleai_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/settings/settings_provider.dart';

part 'ai_search_provider.g.dart';

@riverpod
bool isAISearchAvaliable(Ref ref) {
  final aiSearchEnabled = ref.watch(aiSearchEnabledProvider);
  final geminiApiToken = ref.watch(geminiApiTokenProvider);

  return aiSearchEnabled && geminiApiToken != null;
}

class AIChatState {
  final GoogleAIClient ai;
  final List<String> messages;
  final bool isLoading;
  final String? error;

  AIChatState({
    required this.ai,
    required this.messages,
    required this.isLoading,
    this.error,
  });

  AIChatState copyWith({
    GoogleAIClient? ai,
    List<String>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AIChatState(
      ai: ai ?? this.ai,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@Riverpod(keepAlive: true)
class AIChat extends _$AIChat {
  late GoogleAIClient ai;

  @override
  AIChatState build() {
    final token = ref.read(geminiApiTokenProvider);

    ai = GoogleAIClient.withApiKey(token ?? "");

    ref.listen(geminiApiTokenProvider, (previous, next) {
      ai = GoogleAIClient.withApiKey(token ?? "");
    });

    return AIChatState(ai: ai, messages: [], isLoading: false);
  }

  Future<void> sendMessage(String text) async {
    final messages = [...state.messages, text];
    state = state.copyWith(isLoading: true, messages: messages);

    try {
      final response = await ai.models.generateContent(
        model: "gemini-2.5-flash",
        request: GenerateContentRequest(
          contents: [],
          generationConfig: GenerationConfig(),
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
