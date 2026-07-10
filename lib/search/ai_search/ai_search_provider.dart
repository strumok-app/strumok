import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strumok/settings/settings_provider.dart';

part 'ai_search_provider.g.dart';

const systemInstruction = """
# Role & Objective
You are a deeply knowledgeable, hyper-personalized Pop Culture specializing in TV Shows Movies, Manga, and Anime. 
Your sole objective is to discover user preferences, decode their underlying tastes, and provide highly accurate, compelling recommendations across these three mediums. 
You are not a generic search engine; you are a passionate, analytical curator who understands the distinct nuances of otaku culture, cinematic grammar, and narrative structures.
Not all request should  return recommendations. If the user is asking for information, context, or analysis, provide that instead of recommendations.

## Interaction & Discovery Protocol
*   **Decouple the Niche:** Do not rely solely on generic genres (e.g., "Shonen" or "Action"). Instead, identify the specific sub-elements the user enjoys, such as:
    *   *Tropes:* Found family, enemies-to-lovers, zero-to-hero, complex magic systems, political intrigue.
    *   *Pacing:* Slow-burn slice-of-life, breakneck thriller, episodic vs. hyper-serialized.
    *   *Aesthetics/Tone:* Grimdark, neon-cyberpunk, nostalgic retro-90s, avant-garde, pastel cozy.
*   **Dynamic Intake:** If a user asks for general recommendations, ask **one** highly targeted clarifying question to narrow down their mood rather than overwhelming them with a multi-step survey. (e.g., "Are you looking for an epic, completed manga with deep world-building, or a short, unhinged thriller movie to watch tonight?")

## Media-Specific Rules
*   **The Adaptation Bridge:** Always be aware of the cross-pollination between formats. 
    *   If recommending an **Anime**, briefly note if the **Manga** is superior/more complete, or if the anime has notorious filler seasons.
    *   If recommending a **Manga**, note if it has a faithful ongoing or completed anime adaptation.
*   **Version Clarity:** When recommending anime, specify if a specific season, movie, or remake (e.g., *Fullmetal Alchemist: Brotherhood* vs. 2003) is the definitive starting point.
*   **Movie Nuance:** When recommending live-action or animated movies, pay attention to the Director or Studio footprint (e.g., Satoshi Kon, Denis Villeneuve, Studio Trigger, A24) as a shorthand for style and quality.

## Persona & Tone
*   **Enthusiastic Yet Grounded:** Sound like an incredibly well-read, approachable friend. Use accurate terminology (e.g., *Seinen*, *Josei*, *Macguffin*, *Cinematography*) naturally, without sounding pretentious or elitist.
*   **No Placeholders:** Never give vague or generic suggestions like "You might like popular action movies." Be specific.
*   **Anti-Recency Bias:** Balance popular, trending hits with hidden gems and classic masterpieces. Don't just recommend whatever is airing this season.

## Response format
* title name should be always be in user input language
* Response should be plain JSON Object with the following structure:
  {
    "description": "<Concise description of the recommendations>",
    "recommendations": [
      {
        "title": "<Title of the recommendation>",
      },
      ...
    ]
  }

""";

@riverpod
bool isAISearchAvaliable(Ref ref) {
  final aiSearchEnabled = ref.watch(aiSearchEnabledProvider);
  final geminiApiToken = ref.watch(geminiApiTokenProvider);

  return aiSearchEnabled && geminiApiToken != null;
}

sealed class AIChatMessage {
  const AIChatMessage();
}

class UserMessage extends AIChatMessage {
  final String text;

  const UserMessage(this.text);
}

class AIChatRecommendation {
  final String title;

  const AIChatRecommendation(this.title);
}

class ModelMessage extends AIChatMessage {
  final String description;
  final List<AIChatRecommendation> recommendations;
  final String? error;

  const ModelMessage(this.description, this.recommendations, {this.error});

  factory ModelMessage.fromText(String text) {
    final responseText = text.trim();
    if (responseText.isEmpty) {
      return ModelMessage('', [], error: 'AI response content is empty.');
    }

    try {
      final parsedJson = jsonDecode(responseText);
      if (parsedJson is! Map<String, dynamic>) {
        return ModelMessage(
          '',
          [],
          error: 'AI response JSON is not an object.',
        );
      }

      final description = parsedJson['description'] as String? ?? '';
      final recommendationList =
          parsedJson['recommendations'] as List<dynamic>?;
      final recommendations =
          recommendationList
              ?.whereType<Map<String, dynamic>>()
              .map(
                (item) => AIChatRecommendation(item['title'] as String? ?? ''),
              )
              .toList() ??
          [];

      return ModelMessage(description, recommendations);
    } catch (e) {
      return ModelMessage('', [], error: e.toString());
    }
  }
}

class AIChatState {
  final GoogleAIClient ai;
  final List<AIChatMessage> messages;
  final List<Content> contents;
  final bool isLoading;
  final String? error;

  AIChatState({
    required this.ai,
    required this.messages,
    required this.contents,
    required this.isLoading,
    this.error,
  });

  AIChatState copyWith({
    GoogleAIClient? ai,
    List<AIChatMessage>? messages,
    List<Content>? contents,
    bool? isLoading,
  }) {
    return AIChatState(
      ai: ai ?? this.ai,
      messages: messages ?? this.messages,
      contents: contents ?? this.contents,
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

    return AIChatState(ai: ai, messages: [], contents: [], isLoading: false);
  }

  void reset() {
    state = AIChatState(ai: ai, messages: [], contents: [], isLoading: false);
  }

  Future<void> sendMessage(String text) async {
    text = text.trim();
    if (state.isLoading || text.isEmpty) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      messages: [...state.messages, UserMessage(text)],
      contents: [
        ...state.contents,
        Content.user([TextPart(text)]),
      ],
    );

    try {
      final response = await ai.models.generateContent(
        model: "gemini-3.5-flash",
        request: GenerateContentRequest(
          systemInstruction: Content.text(systemInstruction),
          contents: state.contents,
        ),
      );

      final responseContent = response.candidates?.firstOrNull?.content;
      if (responseContent != null) {
        final responseText = responseContent.parts
            .whereType<TextPart>()
            .map((part) => part.text)
            .join('\n')
            .trim();

        final modelMessage = ModelMessage.fromText(responseText);

        state = state.copyWith(
          isLoading: false,
          messages: [...state.messages, modelMessage],
          contents: [...state.contents, responseContent],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          messages: [
            ...state.messages,
            ModelMessage('', [], error: 'AI response content is empty.'),
          ],
        );
      }
    } catch (e) {
      final errorText = e.toString();
      state = state.copyWith(
        isLoading: false,
        messages: [
          ...state.messages,
          ModelMessage('', [], error: errorText),
        ],
      );
    }
  }
}
