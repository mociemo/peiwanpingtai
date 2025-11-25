import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/storage_utils.dart';

/// 推送通知服务类
class PushNotificationService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// 推送给单个用户
  static Future<bool> pushToUser(String userId, String title, String content, {
    Map<String, String>? extras,
  }) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push/user'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'userId': userId,
          'title': title,
          'content': content,
          if (extras != null) 'extras': json.encode(extras),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 推送给多个用户
  static Future<bool> pushToUsers(List<String> userIds, String title, String content, {
    Map<String, String>? extras,
  }) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push/users'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'userIds': userIds.join(','),
          'title': title,
          'content': content,
          if (extras != null) 'extras': json.encode(extras),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 推送给所有用户
  static Future<bool> pushToAll(String title, String content, {
    Map<String, String>? extras,
  }) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push/all'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'title': title,
          'content': content,
          if (extras != null) 'extras': json.encode(extras),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 推送新消息通知
  static Future<bool> pushNewMessage(String toUserId, String fromUserName, String messageContent) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push/message'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'toUserId': toUserId,
          'fromUserName': fromUserName,
          'messageContent': messageContent,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 推送订单状态变更
  static Future<bool> pushOrderStatus(String userId, String orderNo, String status) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push/order'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'userId': userId,
          'orderNo': orderNo,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 推送通话邀请
  static Future<bool> pushCallInvite(String toUserId, String fromUserName, bool isVideoCall) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push/call'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'toUserId': toUserId,
          'fromUserName': fromUserName,
          'isVideoCall': isVideoCall.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 推送系统通知
  static Future<bool> pushSystemNotification(String title, String content) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/push/system'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'title': title,
          'content': content,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取推送统计信息
  static Future<Map<String, dynamic>?> getPushStats() async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/push/stats'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}