import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/activity_model.dart';

class ActivityService {
  static final Dio _dio = ApiService.dio;

  /// 获取活动列表
  static Future<List<Activity>> getActivities({
    ActivityType? type,
    ActivityStatus? status,
    bool? isTop,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      if (type != null) queryParams['type'] = type.name;
      if (status != null) queryParams['status'] = status.name;
      if (isTop != null) queryParams['isTop'] = isTop;

      final response = await _dio.get(
        '/api/activities',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> activitiesJson = data['data'];
          return activitiesJson
              .map((json) => Activity.fromJson(json))
              .toList();
        }
      }
      throw Exception('获取活动列表失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取活动列表失败: $e');
    }
  }

  /// 获取活动详情
  static Future<Activity> getActivityById(String id) async {
    try {
      final response = await _dio.get('/api/activities/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('获取活动详情失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取活动详情失败: $e');
    }
  }

  /// 创建活动（管理员功能）
  static Future<Activity> createActivity({
    required String title,
    required String description,
    String? imageUrl,
    String? bannerUrl,
    required ActivityType type,
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? rules,
    Map<String, dynamic>? rewards,
    bool isTop = false,
    int sortOrder = 0,
    String? linkUrl,
    String? linkType,
    String? linkId,
  }) async {
    try {
      final response = await _dio.post('/api/activities', data: {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'bannerUrl': bannerUrl,
        'type': type.name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'rules': rules,
        'rewards': rewards,
        'isTop': isTop,
        'sortOrder': sortOrder,
        'linkUrl': linkUrl,
        'linkType': linkType,
        'linkId': linkId,
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('创建活动失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('创建活动失败: $e');
    }
  }

  /// 更新活动（管理员功能）
  static Future<Activity> updateActivity(
    String id, {
    String? title,
    String? description,
    String? imageUrl,
    String? bannerUrl,
    ActivityType? type,
    ActivityStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? rules,
    Map<String, dynamic>? rewards,
    bool? isTop,
    int? sortOrder,
    String? linkUrl,
    String? linkType,
    String? linkId,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      if (bannerUrl != null) data['bannerUrl'] = bannerUrl;
      if (type != null) data['type'] = type.name;
      if (status != null) data['status'] = status.name;
      if (startTime != null) data['startTime'] = startTime.toIso8601String();
      if (endTime != null) data['endTime'] = endTime.toIso8601String();
      if (rules != null) data['rules'] = rules;
      if (rewards != null) data['rewards'] = rewards;
      if (isTop != null) data['isTop'] = isTop;
      if (sortOrder != null) data['sortOrder'] = sortOrder;
      if (linkUrl != null) data['linkUrl'] = linkUrl;
      if (linkType != null) data['linkType'] = linkType;
      if (linkId != null) data['linkId'] = linkId;

      final response = await _dio.put('/api/activities/$id', data: data);
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return Activity.fromJson(responseData['data']);
        }
      }
      throw Exception('更新活动失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('更新活动失败: $e');
    }
  }

  /// 删除活动（管理员功能）
  static Future<bool> deleteActivity(String id) async {
    try {
      final response = await _dio.delete('/api/activities/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('删除活动失败: $e');
    }
  }

  /// 参与活动
  static Future<ActivityParticipant> joinActivity(
    String activityId,
    String userId, {
    Map<String, dynamic>? participationData,
  }) async {
    try {
      final response = await _dio.post('/api/activities/$activityId/join', data: {
        'userId': userId,
        'participationData': participationData,
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return ActivityParticipant.fromJson(data['data']);
        }
      }
      throw Exception('参与活动失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('参与活动失败: $e');
    }
  }

  /// 退出活动
  static Future<bool> leaveActivity(String activityId, String userId) async {
    try {
      final response = await _dio.delete('/api/activities/$activityId/leave', data: {
        'userId': userId,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('退出活动失败: $e');
    }
  }

  /// 获取活动参与者列表
  static Future<List<ActivityParticipant>> getActivityParticipants(
    String activityId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/activities/$activityId/participants',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> participantsJson = data['data'];
          return participantsJson
              .map((json) => ActivityParticipant.fromJson(json))
              .toList();
        }
      }
      throw Exception('获取活动参与者失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取活动参与者失败: $e');
    }
  }

  /// 增加活动浏览次数
  static Future<bool> incrementActivityView(String activityId) async {
    try {
      final response = await _dio.post('/api/activities/$activityId/view');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('增加浏览次数失败: $e');
    }
  }

  /// 增加活动分享次数
  static Future<bool> incrementActivityShare(String activityId) async {
    try {
      final response = await _dio.post('/api/activities/$activityId/share');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('增加分享次数失败: $e');
    }
  }

  /// 获取活动统计信息
  static Future<Map<String, dynamic>> getActivityStats(String activityId) async {
    try {
      final response = await _dio.get('/api/activities/$activityId/stats');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('获取活动统计失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取活动统计失败: $e');
    }
  }

  /// 发布活动（管理员功能）
  static Future<Activity> publishActivity(String activityId) async {
    try {
      final response = await _dio.post('/api/activities/$activityId/publish');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Activity.fromJson(data['data']);
        }
      }
      throw Exception('发布活动失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('发布活动失败: $e');
    }
  }
}