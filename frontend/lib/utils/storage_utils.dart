import 'package:shared_preferences/shared_preferences.dart';

/// 存储工具类
class StorageUtils {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _userTypeKey = 'user_type';

  /// 保存Token
  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      return false;
    }
  }

  /// 获取Token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// 删除Token
  static Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      return false;
    }
  }

  /// 保存用户ID
  static Future<bool> saveUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_userIdKey, userId);
    } catch (e) {
      return false;
    }
  }

  /// 获取用户ID
  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  /// 删除用户ID
  static Future<bool> removeUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userIdKey);
    } catch (e) {
      return false;
    }
  }

  /// 保存用户名
  static Future<bool> saveUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_usernameKey, username);
    } catch (e) {
      return false;
    }
  }

  /// 获取用户名
  static Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      return null;
    }
  }

  /// 删除用户名
  static Future<bool> removeUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_usernameKey);
    } catch (e) {
      return false;
    }
  }

  /// 保存用户类型
  static Future<bool> saveUserType(String userType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userTypeKey, userType);
    } catch (e) {
      return false;
    }
  }

  /// 获取用户类型
  static Future<String?> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTypeKey);
    } catch (e) {
      return null;
    }
  }

  /// 删除用户类型
  static Future<bool> removeUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userTypeKey);
    } catch (e) {
      return false;
    }
  }

  /// 清除所有存储数据
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      return false;
    }
  }

  /// 保存任意键值对
  static Future<bool> saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      return false;
    }
  }

  /// 获取任意键值
  static Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      return null;
    }
  }

  /// 删除任意键值
  static Future<bool> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }
}