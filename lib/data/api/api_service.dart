import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../utils/const.dart';
import '../db/preference.dart';
import '../model/user.dart';
import '../response/story_response.dart';
import '../response/upload_response.dart';
import 'package:http/http.dart';
import 'endpoint.dart';

class ApiService {
  final Client client;
  ApiService(this.client);

  Future<String> register(
      String name,
      String email,
      String password,
      ) async {
    try {
      var body = {
        'name': name,
        'email': email,
        'password': password,
      };

      var url = storyRegister;
      debugPrint("register API POST: $url");

      var client = http.Client();

      final response = await client.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
      );

      client.close();
      if (response.statusCode == 201) {
        return json.decode(response.body)['message'];
      } else {
        debugPrint(json.decode(response.body)['message']);
        throw json.decode(response.body)['message'];
      }
    } catch (e) {
      throw Exception('Api register error : $e');
    }
  }

  Future<User> login(String email, String password) async {
    try {
      var body = {
        'email': email,
        'password': password,
      };

      var url = storyLogin;
      debugPrint("login API POST: $url");

      var client = http.Client();

      final response = await client.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
      );

      client.close();

      if (response.statusCode == 200) {
        await putStorageBoolean(loginData, true);
        saveOAuthData(response.body);
        return User.fromJson(json.decode(response.body));
      } else {
        debugPrint(response.body);
        throw User.fromJson(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('$e');
      throw Exception('Api register error : $e');
    }
  }

  Future<UploadResponse> uploadDocument(
      List<int> bytes,
      String fileName,
      String description,
      [double lat = 0.0,
        double lon = 0.0,]
      ) async {
    const String url = storyUpload;

    final uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);

    final multiPartFile = http.MultipartFile.fromBytes(
      "photo",
      bytes,
      filename: fileName,
    );
    final Map<String, String> fields = {
      "description": description,
      "lat": lat.toString(),
      "lon": lon.toString(),
    };
    final Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await getOAuthData()}"
    };

    request.files.add(multiPartFile);
    request.fields.addAll(fields);
    request.headers.addAll(headers);

    final http.StreamedResponse streamedResponse = await request.send();
    final int statusCode = streamedResponse.statusCode;

    final Uint8List responseList = await streamedResponse.stream.toBytes();
    final String responseData = String.fromCharCodes(responseList);

    if (statusCode == 201) {
      final UploadResponse uploadResponse = UploadResponse.fromJson(
        responseData as Map<String, dynamic>,
      );
      return uploadResponse;
    } else {
      throw Exception("Upload file error");
    }
  }
  

  Future<StoryResponse> getStoriesList(
      [int page = 1, int size = 10, int location = 1]) async {
    try {
      var url = '$storyGetStory?page=$page&size=$size&location=$location';
      debugPrint("list stories API GET: $url");

      var client = http.Client();

      final response = await client.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await getOAuthData()}"
        },
      );

      client.close();
      if (response.statusCode == 200) {
        debugPrint(response.body);
        return StoryResponse.fromJson(json.decode(response.body));
      } else {
        throw StoryResponse.fromJson(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('$e');
      throw Exception('Api get data error : $e');
    }
  }


  Future<void> saveOAuthData(String token) async {
    await putStorage(authData, token);
  }

  Future<String> getOAuthData() async {
    var data = await getStorage(authData);
    var token = json.decode(data!);
    debugPrint(token['loginResult']['token']);
    return token['loginResult']['token'];
  }

}

final apiService = ApiService(Client());