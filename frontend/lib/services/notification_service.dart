import 'package:dio/dio.dart';
import 'api_service.dart';

class NotificationService {
  static final Dio _dio = ApiService.dio;

  /// 获取通知列表
  static Future<List<Map<String, dynamic>>> getNotifications({
    int page = 0,
    int size = 20,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      
      if (type != null) {
        queryParams['type'] = type;
      }
      
      final response = await _dio.get('/notifications', queryParameters: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('获取通知列表失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 标记通知为已读
  static Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _dio.put('/notifications/$notificationId/read');
      
      if (response.data['success'] != true) {
        throw Exception('标记已读失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 批量标记为已读
  static Future<void> markAllAsRead() async {
    try {
      final response = await _dio.put('/notifications/read-all');
      
      if (response.data['success'] != true) {
        throw Exception('批量标记已读失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 删除通知
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete('/notifications/$notificationId');
      
      if (response.data['success'] != true) {
        throw Exception('删除通知失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取未读通知数量
  static Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      
      if (response.data['success'] == true) {
        return response.data['data'] ?? 0;
      } else {
        throw Exception('获取未读数量失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 发送推送通知token
  static Future<void> registerPushToken(String token) async {
    try {
      final response = await _dio.post('/notifications/push-token', data: {
        'token': token,
      });
      
      if (response.data['success'] != true) {
        throw Exception('注册推送token失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取通知设置
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await _dio.get('/notifications/settings');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('获取通知设置失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新通知设置
  static Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _dio.put('/notifications/settings', data: settings);
      
      if (response.data['success'] != true) {
        throw Exception('更新通知设置失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }
}