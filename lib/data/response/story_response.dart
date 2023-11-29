import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

import '../model/list_story.dart';

part 'story_response.g.dart';

@JsonSerializable()
class StoryResponse {
  bool error;
  String message;
  List<ListStory>? listStory;

  StoryResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory StoryResponse.fromRawJson(String str) => StoryResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoryResponse.fromJson(Map<String, dynamic> json) => _$StoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoryResponseToJson(this);
}



