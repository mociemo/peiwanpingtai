import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';
import '../config/api_config.dart';
import '../utils/storage_utils.dart';

class ActivityService {
  static const String _baseUrl = ApiConfig.baseUrl;
  
  static Future<List<Activity>> getAllActivities() async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activities'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> activitiesJson = data['data'];
          return activitiesJson.map((json) => Activity.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load activities');
    } catch (e) {
      throw Exception('获取活动列表失败: $e');
    }
  }

  static Future<List<Activity>> getActiveActivities() async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activities/active'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> activitiesJson = data['data'];
          return activitiesJson.map((json) => Activity.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load active activities');
    } catch (e) {
      throw Exception('获取活跃活动失败: $e');
    }
  }

  static Future<List<Activity>> getOngoingActivities() async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activities/ongoing'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> activitiesJson = data['data'];
          return activitiesJson.map((json) => Activity.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load ongoing activities');
    } catch (e) {
      throw Exception('获取进行中活动失败: $e');
    }
  }

  static Future<Activity?> getActivityById(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activities/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Activity.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('获取活动详情失败: $e');
    }
  }

  static Future<List<Activity>> getActivitiesByStatus(String status) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activities/status/$status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> activitiesJson = data['data'];
          return activitiesJson.map((json) => Activity.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load activities by status');
    } catch (e) {
      throw Exception('按状态获取活动失败: $e');
    }
  }

  static Future<Activity> createActivity(Activity activity) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activities'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(activity.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create activity');
    } catch (e) {
      throw Exception('创建活动失败: $e');
    }
  }

  static Future<Activity> updateActivity(int id, Activity activity) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/activities/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(activity.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('Failed to update activity');
    } catch (e) {
      throw Exception('更新活动失败: $e');
    }
  }

  static Future<bool> deleteActivity(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/activities/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('删除活动失败: $e');
    }
  }

  static Future<Activity> joinActivity(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activities/$id/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('Failed to join activity');
    } catch (e) {
      throw Exception('参加活动失败: $e');
    }
  }

  static Future<Activity> leaveActivity(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activities/$id/leave'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('Failed to leave activity');
    } catch (e) {
      throw Exception('退出活动失败: $e');
    }
  }

  // 添加缺少的方法
  static Future<List<Activity>> getActivities() async {
    return getAllActivities();
  }

  static Future<Activity> incrementActivityView(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activities/$id/view'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('Failed to increment activity view');
    } catch (e) {
      throw Exception('增加活动浏览量失败: $e');
    }
  }

  static Future<Activity> incrementActivityShare(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activities/$id/share'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('Failed to increment activity share');
    } catch (e) {
      throw Exception('增加活动分享数失败: $e');
    }
  }
}