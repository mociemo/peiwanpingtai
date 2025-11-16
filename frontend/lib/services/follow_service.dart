import 'package:dio/dio.dart';
import '../models/follow_model.dart';
import 'api_service.dart';

class FollowService {
  static final Dio _dio = ApiService.dio;

  /// 获取粉丝列表
  static Future<List<FollowRelationship>> getFollowers({
    required int userId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get('/follows/followers/$userId', queryParameters: {
        'page': page,
        'size': size,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => FollowRelationship.fromJson(item)).toList();
      } else {
        throw Exception('获取粉丝列表失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取关注列表
  static Future<List<FollowRelationship>> getFollowing({
    required int userId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get('/follows/following/$userId', queryParameters: {
        'page': page,
        'size': size,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => FollowRelationship.fromJson(item)).toList();
      } else {
        throw Exception('获取关注列表失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 检查是否关注
  static Future<bool> isFollowing({
    required int targetUserId,
  }) async {
    try {
      final response = await _dio.get('/follows/is-following/$targetUserId');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('检查关注状态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 关注用户
  static Future<FollowRelationship> followUser({
    required int targetUserId,
  }) async {
    try {
      final response = await _dio.post('/follows', data: {
        'targetUserId': targetUserId,
      });

      if (response.data['success'] == true) {
        return FollowRelationship.fromJson(response.data['data']);
      } else {
        throw Exception('关注用户失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 取消关注
  static Future<void> unfollowUser({
    required int targetUserId,
  }) async {
    try {
      final response = await _dio.delete('/follows/$targetUserId');

      if (response.data['success'] == true) {
        return;
      } else {
        throw Exception('取消关注失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取用户统计数据
  static Future<UserStats> getUserStats({
    required int userId,
  }) async {
    try {
      final response = await _dio.get('/follows/stats/$userId');

      if (response.data['success'] == true) {
        return UserStats.fromJson(response.data['data']);
      } else {
        throw Exception('获取用户统计数据失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取共同关注
  static Future<List<FollowRelationship>> getMutualFollowers({
    required int targetUserId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get('/follows/mutual-followers/$targetUserId', queryParameters: {
        'page': page,
        'size': size,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => FollowRelationship.fromJson(item)).toList();
      } else {
        throw Exception('获取共同关注失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }
}