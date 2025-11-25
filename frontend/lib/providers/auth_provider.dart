import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  /// 全局认证提供者实例
  static AuthProvider? globalAuthProvider;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userInfo;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userInfo => _userInfo;
  
  /// 获取用户ID
  String? get userId {
    return _userInfo?['id']?.toString();
  }

  String? _errorMessage;
  
  /// 获取错误信息
  String? get errorMessage => _errorMessage;
  
  /// 设置错误信息
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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
        
        // 同步更新UserProvider
        if (_userInfo != null) {
          // 通过全局状态管理器同步用户信息
          _syncUserInfoToOtherProviders();
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String password, String? email, String? phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(username, password, email, phone);
      
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
    
    notifyListeners(); // 确保UserProvider能收到更新
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await ApiService.getUserInfo();
      if (response['success']) {
        _userInfo = response['data'];
        notifyListeners(); // 确保UserProvider能收到更新
      }
    } catch (e) {
      // 用户信息加载失败，可能是token过期，清除认证状态
      debugPrint('用户信息加载失败: $e');
      await logout(); // 清除认证状态
      setError('登录已过期，请重新登录');
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

  Future<void> refreshUserInfo() async {
    try {
      final response = await ApiService.getUserInfo();
      if (response['success']) {
        _userInfo = response['data'];
        notifyListeners();
      }
    } catch (e) {
      // 用户信息加载失败，记录到日志并通知用户
      debugPrint('用户信息加载失败: $e');
      setError('加载用户信息失败，请检查网络连接');
    }
  }

  /// 同步用户信息到其他Provider
  void _syncUserInfoToOtherProviders() {
    // 这里可以通过事件总线或其他状态管理方案
    // 将用户信息同步到其他需要用户信息的Provider
    // 目前使用SharedPreferences作为中介存储
    _updateUserPreferences();
  }

  /// 更新用户偏好设置
  void _updateUserPreferences() async {
    if (_userInfo != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_info', jsonEncode(_userInfo));
    }
  }
}