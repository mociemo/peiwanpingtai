import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/app_settings_model.dart';

class SettingsService {
  static final Dio _dio = ApiService.dio;

  /// 获取用户设置
  static Future<AppSettings> getUserSettings(String userId) async {
    try {
      final response = await _dio.get('/api/settings/user/$userId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AppSettings.fromJson(data['data']);
        }
      }
      throw Exception('获取用户设置失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取用户设置失败: $e');
    }
  }

  /// 更新用户设置
  static Future<AppSettings> updateUserSettings(
    String userId, {
    bool? pushNotificationEnabled,
    Map<NotificationType, bool>? notificationTypes,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? inAppNotificationEnabled,
    bool? profilePublic,
    bool? showOnlineStatus,
    bool? allowStrangerMessage,
    bool? allowFollowRequest,
    AppThemeMode? themeMode,
    double? fontSize,
    bool? autoPlayVideo,
    bool? highQualityImage,
    bool? autoUpdate,
    String? language,
    bool? cacheEnabled,
    int? cacheSize,
  }) async {
    try {
      final Map<String, dynamic> data = {'userId': userId};
      
      if (pushNotificationEnabled != null) {
        data['pushNotificationEnabled'] = pushNotificationEnabled;
      }
      if (notificationTypes != null) {
        data['notificationTypes'] = notificationTypes.map(
          (key, value) => MapEntry(key.name, value),
        );
      }
      if (soundEnabled != null) data['soundEnabled'] = soundEnabled;
      if (vibrationEnabled != null) data['vibrationEnabled'] = vibrationEnabled;
      if (inAppNotificationEnabled != null) {
        data['inAppNotificationEnabled'] = inAppNotificationEnabled;
      }
      if (profilePublic != null) data['profilePublic'] = profilePublic;
      if (showOnlineStatus != null) data['showOnlineStatus'] = showOnlineStatus;
      if (allowStrangerMessage != null) {
        data['allowStrangerMessage'] = allowStrangerMessage;
      }
      if (allowFollowRequest != null) {
        data['allowFollowRequest'] = allowFollowRequest;
      }
      if (themeMode != null) data['themeMode'] = themeMode.name;
      if (fontSize != null) data['fontSize'] = fontSize;
      if (autoPlayVideo != null) data['autoPlayVideo'] = autoPlayVideo;
      if (highQualityImage != null) data['highQualityImage'] = highQualityImage;
      if (autoUpdate != null) data['autoUpdate'] = autoUpdate;
      if (language != null) data['language'] = language;
      if (cacheEnabled != null) data['cacheEnabled'] = cacheEnabled;
      if (cacheSize != null) data['cacheSize'] = cacheSize;

      final response = await _dio.put('/api/settings/user/$userId', data: data);
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return AppSettings.fromJson(responseData['data']);
        }
      }
      throw Exception('更新用户设置失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('更新用户设置失败: $e');
    }
  }

  /// 重置用户设置为默认值
  static Future<AppSettings> resetUserSettings(String userId) async {
    try {
      final response = await _dio.post('/api/settings/user/$userId/reset');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AppSettings.fromJson(data['data']);
        }
      }
      throw Exception('重置用户设置失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('重置用户设置失败: $e');
    }
  }

  /// 导出用户设置
  static Future<Map<String, dynamic>> exportUserSettings(String userId) async {
    try {
      final response = await _dio.get('/api/settings/user/$userId/export');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('导出用户设置失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('导出用户设置失败: $e');
    }
  }

  /// 导入用户设置
  static Future<AppSettings> importUserSettings(
    String userId,
    Map<String, dynamic> settingsData,
  ) async {
    try {
      final response = await _dio.post(
        '/api/settings/user/$userId/import',
        data: settingsData,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AppSettings.fromJson(data['data']);
        }
      }
      throw Exception('导入用户设置失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('导入用户设置失败: $e');
    }
  }

  /// 获取系统默认设置
  static Future<AppSettings> getDefaultSettings() async {
    try {
      final response = await _dio.get('/api/settings/default');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return AppSettings.fromJson(data['data']);
        }
      }
      throw Exception('获取默认设置失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取默认设置失败: $e');
    }
  }

  /// 清除用户缓存
  static Future<bool> clearUserCache(String userId) async {
    try {
      final response = await _dio.delete('/api/settings/user/$userId/cache');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('清除用户缓存失败: $e');
    }
  }

  /// 获取应用版本信息
  static Future<Map<String, dynamic>> getAppVersionInfo() async {
    try {
      final response = await _dio.get('/api/settings/version');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('获取版本信息失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取版本信息失败: $e');
    }
  }

  /// 检查应用更新
  static Future<Map<String, dynamic>> checkAppUpdate({
    required String currentVersion,
    required String platform,
  }) async {
    try {
      final response = await _dio.get('/api/settings/check-update', queryParameters: {
        'currentVersion': currentVersion,
        'platform': platform,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('检查应用更新失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('检查应用更新失败: $e');
    }
  }
}