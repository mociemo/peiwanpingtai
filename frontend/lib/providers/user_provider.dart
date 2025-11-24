import 'package:flutter/foundation.dart';

/// 用户状态管理
class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// 检查用户是否登录
  bool get isLoggedIn => _currentUser != null;

  /// 获取用户信息（兼容旧代码）
  Map<String, dynamic>? get user => _currentUser;

  /// 设置当前用户
  void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
    notifyListeners();
  }

  /// 更新用户信息
  void updateUser(Map<String, dynamic> updates) {
    if (_currentUser != null) {
      _currentUser = {..._currentUser!, ...updates};
      notifyListeners();
    }
  }

  /// 清除当前用户
  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }
}