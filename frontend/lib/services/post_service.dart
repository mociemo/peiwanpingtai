import 'package:dio/dio.dart';
import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  static final Dio _dio = ApiService.dio;

  /// 获取动态列表
  static Future<List<Post>> getPosts({
    int page = 0,
    int size = 20,
    String status = 'PUBLISHED',
    String sort = 'createTime',
    String direction = 'desc',
  }) async {
    try {
      final response = await _dio.get('/posts', queryParameters: {
        'page': page,
        'size': size,
        'status': status,
        'sort': sort,
        'direction': direction,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('获取动态列表失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取用户动态
  static Future<List<Post>> getUserPosts({
    required String userId,
    int page = 0,
    int size = 20,
    String status = 'PUBLISHED',
  }) async {
    try {
      final response = await _dio.get('/posts/user/$userId', queryParameters: {
        'page': page,
        'size': size,
        'status': status,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('获取用户动态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 搜索动态
  static Future<List<Post>> searchPosts({
    required String keyword,
    int page = 0,
    int size = 20,
    String status = 'PUBLISHED',
  }) async {
    try {
      final response = await _dio.get('/posts/search', queryParameters: {
        'keyword': keyword,
        'page': page,
        'size': size,
        'status': status,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('搜索动态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 创建动态
  static Future<Post> createPost({
    required String content,
    String? imageUrls,
    String postType = 'TEXT',
    String? gameName,
  }) async {
    try {
      final response = await _dio.post('/posts', data: {
        'content': content,
        'imageUrls': imageUrls,
        'postType': postType,
        'gameName': gameName,
      });

      if (response.data['success'] == true) {
        return Post.fromJson(response.data['data']);
      } else {
        throw Exception('创建动态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新动态
  static Future<Post> updatePost({
    required String postId,
    required String content,
    String? imageUrls,
    String? gameName,
  }) async {
    try {
      final response = await _dio.put('/posts/$postId', data: {
        'content': content,
        'imageUrls': imageUrls,
        'gameName': gameName,
      });

      if (response.data['success'] == true) {
        return Post.fromJson(response.data['data']);
      } else {
        throw Exception('更新动态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 删除动态
  static Future<void> deletePost(String postId) async {
    try {
      final response = await _dio.delete('/posts/$postId');

      if (response.data['success'] == true) {
        return;
      } else {
        throw Exception('删除动态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 点赞动态
  static Future<void> likePost(String postId) async {
    try {
      final response = await _dio.post('/posts/$postId/like');

      if (response.data['success'] == true) {
        return;
      } else {
        throw Exception('点赞失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 取消点赞
  static Future<void> unlikePost(String postId) async {
    try {
      final response = await _dio.post('/posts/$postId/unlike');

      if (response.data['success'] == true) {
        return;
      } else {
        throw Exception('取消点赞失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取动态详情
  static Future<Post> getPostById(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId');

      if (response.data['success'] == true) {
        return Post.fromJson(response.data['data']);
      } else {
        throw Exception('获取动态详情失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取关注用户的动态
  static Future<List<Post>> getFollowingPosts({
    required List<String> userIds,
    int page = 0,
    int size = 20,
    String status = 'PUBLISHED',
  }) async {
    try {
      final response = await _dio.get('/posts/following', queryParameters: {
        'userIds': userIds.join(','),
        'page': page,
        'size': size,
        'status': status,
      });

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('获取关注用户动态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }
}