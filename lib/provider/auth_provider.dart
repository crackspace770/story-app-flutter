
import 'package:flutter/material.dart';
import 'package:story_app/data/api/api_service.dart';
import '../data/db/preference.dart';
import '../data/model/user.dart';
import '../data/response/user_response.dart';
import '../utils/const.dart';


class AuthProvider extends ChangeNotifier {

  bool isLoadingLogin = false;
  bool isLoadingLogout = false;
  bool isLoadingRegister = false;
  bool isLoggedIn = false;


  Future<String> register(
      String name,
      String email,
      String password,
      ) async {
    try {
      isLoadingRegister = true;
      notifyListeners();

      final registerState = await apiService.register(name, email, password);

      isLoadingRegister = false;
      notifyListeners();

      return registerState;
    } catch (e) {
      isLoadingRegister = false;
      notifyListeners();
      throw Exception('Error Api Register : $e');
    }
  }

  Future<User> login(
      String email,
      String password,
      ) async {
    try {
      isLoadingLogin = true;
      notifyListeners();

      final loginState = await apiService.login(
        email,
        password,
      );

      isLoggedIn = await getStorageBoolean(loginData);

      isLoadingLogin = false;
      notifyListeners();

      return loginState;
    } catch (e) {
      isLoadingLogin = false;
      notifyListeners();
      throw Exception('Error Api Login : $e');
    }
  }

  Future<bool> logout() async {
    isLoadingLogout = true;
    notifyListeners();

    await removeStorage(authData);
    final logout = await removeStorage(loginData);
    if (logout) {
      await putStorageBoolean(loginData, false);
      isLoggedIn = await getStorageBoolean(loginData);
    }
    isLoadingLogout = false;
    notifyListeners();

    return !isLoggedIn;
  }
}