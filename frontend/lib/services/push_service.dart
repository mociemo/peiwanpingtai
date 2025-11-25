import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../providers/auth_provider.dart' as auth;

/// 推送服务
/// 处理离线推送通知
class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  /// 推送给单个用户
  static Future<bool> pushToUser(
    String userId,
    String title,
    String content, {
    Map<String, String>? extras,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/push/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'content': content,
          'extras': extras ?? {},
        }),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('推送失败: $e');
      return false;
    }
  }

  /// 推送给多个用户
  static Future<bool> pushToUsers(
    List<String> userIds,
    String title,
    String content, {
    Map<String, String>? extras,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/push/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({
          'userIds': userIds,
          'title': title,
          'content': content,
          'extras': extras ?? {},
        }),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('群推送失败: $e');
      return false;
    }
  }

  /// 推送给所有用户
  static Future<bool> pushToAll(
    String title,
    String content, {
    Map<String, String>? extras,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/push/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'extras': extras ?? {},
        }),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('全量推送失败: $e');
      return false;
    }
  }

  /// 推送新消息通知
  static Future<bool> pushNewMessage(
    String toUserId,
    String fromUserName,
    String messageContent,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/push/message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({
          'toUserId': toUserId,
          'fromUserName': fromUserName,
          'messageContent': messageContent,
        }),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('消息推送失败: $e');
      return false;
    }
  }

  /// 推送订单状态变更
  static Future<bool> pushOrderStatusChange(
    String userId,
    String orderNo,
    String status,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/push/order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({
          'userId': userId,
          'orderNo': orderNo,
          'status': status,
        }),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('订单状态推送失败: $e');
      return false;
    }
  }

  /// 推送通话邀请
  static Future<bool> pushCallInvite(
    String toUserId,
    String fromUserName,
    bool isVideoCall,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/push/call'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({
          'toUserId': toUserId,
          'fromUserName': fromUserName,
          'isVideoCall': isVideoCall,
        }),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('通话邀请推送失败: $e');
      return false;
    }
  }

  /// 推送系统通知
  static Future<bool> pushSystemNotification(
    String title,
    String content,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/push/system'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
        }),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('系统通知推送失败: $e');
      return false;
    }
  }

  /// 获取推送统计信息
  static Future<Map<String, dynamic>?> getPushStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/push/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.AuthProvider.globalAuthProvider?.token ?? ''}',
        },
      );

      final result = _handleHttpResponse(response);
      if (result['success'] == true) {
        return result['data'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('获取推送统计失败: $e');
      return null;
    }
  }

  /// 获取全局认证提供者
  static auth.AuthProvider? get globalAuthProvider => auth.AuthProvider.globalAuthProvider;
}

/// 处理HTTP响应
Map<String, dynamic> _handleHttpResponse(http.Response response) {
  try {
    final responseData = json.decode(response.body);
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
    return {'success': false, 'message': '响应格式错误'};
  } catch (e) {
    return {'success': false, 'message': '响应解析失败: $e'};
  }
}