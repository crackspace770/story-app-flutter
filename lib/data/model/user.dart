
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../response/user_response.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  bool error;
  String message;
  LoginResult loginResult;

  User({
    required this.error,
    required this.message,
    required this.loginResult,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}