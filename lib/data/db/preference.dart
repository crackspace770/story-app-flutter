
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getStorage(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.delayed(const Duration(seconds: 2));
  return prefs.getString(key);
}

Future<bool> getStorageBoolean(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.delayed(const Duration(seconds: 2));
  return prefs.getBool(key) ?? false;
}

Future<bool> putStorage(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.delayed(const Duration(seconds: 2));
  return prefs.setString(key, value);
}

Future<bool> putStorageBoolean(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.delayed(const Duration(seconds: 2));
  return prefs.setBool(key, value);
}

Future<bool> removeStorage(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.delayed(const Duration(seconds: 2));
  return prefs.remove(key);
}

Future<bool> clearStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Future.delayed(const Duration(seconds: 2));
  return prefs.clear();
}