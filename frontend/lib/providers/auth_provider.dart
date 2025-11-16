import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userInfo;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get userId => _userInfo?['id'];

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      _token = token;
      _isAuthenticated = true;
      // 加载用户信息
      await _loadUserInfo();
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);

      if (response['success']) {
        _token = response['data']['token'];
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        await _loadUserInfo();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String username,
    String password,
    String email,
    String phone,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(
        username,
        password,
        email,
        phone,
      );

      if (response['success']) {
        // 注册成功后自动登录
        await login(username, password);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    _token = null;
    _isAuthenticated = false;
    _userInfo = null;

    notifyListeners();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await ApiService.getUserInfo();
      if (response['success']) {
        _userInfo = response['data'];
      }
    } catch (e) {
      // 忽略用户信息加载错误
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.updateUserInfo(userData);
      if (response['success']) {
        _userInfo = {...?_userInfo, ...userData};
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
