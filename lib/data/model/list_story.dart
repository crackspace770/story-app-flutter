
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'list_story.g.dart';

@JsonSerializable()
class ListStory {
  String id;
  String name;
  String description;
  String photoUrl;
  DateTime createdAt;
  double lat;
  double lon;


  ListStory({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    required this.lat,
    required this.lon,
  });

  factory ListStory.fromRawJson(String str) => ListStory.fromJson(json.decode(str));

  String toJson() => json.encode(toJson());

  factory ListStory.fromJson(Map<String, dynamic> json) => _$ListStoryFromJson(json);

  Map<String, dynamic> toMap() => _$ListStoryToJson(this);
}