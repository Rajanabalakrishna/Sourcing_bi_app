import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mukadam_bi/mukadan/authentication/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service/auth_service.dart';
//import 'models/user_model.dart'; // Ensure this matches your file name

class UserProvider with ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user_data');
    final String? savedToken = prefs.getString('session_token');

    if (userJson != null && savedToken != null) {
      _user = User.fromJson(jsonDecode(userJson));
      _token = savedToken;
      notifyListeners();
    }
  }

  void setUserData(AuthResponse response)async {
    _user = response.user;
    _token = response.token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bg_user_id', response.user.id);
    notifyListeners();
  }

  Future<void> logout() async { // <--- Change void to Future<void>
    _user = null;
    _token = null;

    OtpApiService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }




}
