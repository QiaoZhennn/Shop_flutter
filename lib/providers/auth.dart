import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/api_keys.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expireDate != null && _expireDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String url = AUTH_URL_BASE + urlSegment + '?' + AUTH_URL_KEY;
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners(); // will notify main.dart to rebuild MaterialApp because it is wraped with Consumer
      var prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expireDate': _expireDate!.toIso8601String()
      });
      await prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    String jsonstr = prefs.getString('userData') ?? '';
    try {
      final extractedUserData = json.decode(jsonstr) as Map<String, dynamic>;
      final expireDate = DateTime.parse(extractedUserData['expireDate']);
      if (expireDate.isBefore(DateTime.now())) {
        print('expire');
        return false;
      }
      _token = extractedUserData['token'];
      _userId = extractedUserData['userId'];
      _expireDate = expireDate;
    } catch (e) {
      print(e);
    }
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpire = _expireDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }
}
