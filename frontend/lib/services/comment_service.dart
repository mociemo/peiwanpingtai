import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import 'api_service.dart';

class CommentService {
  static final Dio _dio = ApiService.dio;

  /// 获取动态评论列表
  static Future<List<Comment>> getCommentsByPostId({
    required int postId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/comments/post/$postId',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => Comment.fromJson(item)).toList();
      } else {
        throw Exception('获取评论列表失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取用户评论
  static Future<List<Comment>> getCommentsByUserId({
    required int userId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/comments/user/$userId',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => Comment.fromJson(item)).toList();
      } else {
        throw Exception('获取用户评论失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 创建评论
  static Future<Comment> createComment({
    required int postId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final response = await _dio.post(
        '/comments',
        data: {
          'postId': postId,
          'content': content,
          'parentCommentId': parentCommentId,
        },
      );

      if (response.data['success'] == true) {
        return Comment.fromJson(response.data['data']);
      } else {
        throw Exception('创建评论失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新评论
  static Future<Comment> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final response = await _dio.put(
        '/comments/$commentId',
        data: {'content': content},
      );

      if (response.data['success'] == true) {
        return Comment.fromJson(response.data['data']);
      } else {
        throw Exception('更新评论失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 删除评论
  static Future<void> deleteComment(int commentId) async {
    try {
      final response = await _dio.delete('/comments/$commentId');

      if (response.data['success'] == true) {
        return;
      } else {
        throw Exception('删除评论失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 点赞评论
  static Future<void> likeComment(int commentId) async {
    try {
      final response = await _dio.post('/comments/$commentId/like');

      if (response.data['success'] == true) {
        return;
      } else {
        throw Exception('点赞评论失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 取消点赞评论
  static Future<void> unlikeComment(int commentId) async {
    try {
      final response = await _dio.post('/comments/$commentId/unlike');

      if (response.data['success'] == true) {
        return;
      } else {
        throw Exception('取消点赞评论失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取评论详情
  static Future<Comment> getCommentById(int commentId) async {
    try {
      final response = await _dio.get('/comments/$commentId');

      if (response.data['success'] == true) {
        return Comment.fromJson(response.data['data']);
      } else {
        throw Exception('获取评论详情失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }
}
