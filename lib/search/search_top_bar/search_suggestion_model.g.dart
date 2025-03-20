// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchSuggestion _$SearchSuggestionFromJson(Map<String, dynamic> json) =>
    SearchSuggestion(
      text: json['text'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      tokens:
          (json['tokens'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SearchSuggestionToJson(SearchSuggestion instance) =>
    <String, dynamic>{
      'text': instance.text,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'tokens': instance.tokens,
    };
