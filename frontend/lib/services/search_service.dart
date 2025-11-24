import 'package:dio/dio.dart';
import 'api_service.dart';

class SearchService {
  static final Dio _dio = ApiService.dio;

  /// 搜索用户
  static Future<List<Map<String, dynamic>>> searchUsers({
    required String keyword,
    int page = 0,
    int size = 20,
    String? gameType,
    String? skillLevel,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'keyword': keyword,
        'page': page,
        'size': size,
      };
      
      if (gameType != null) queryParams['gameType'] = gameType;
      if (skillLevel != null) queryParams['skillLevel'] = skillLevel;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      
      final response = await _dio.get('/search/users', queryParameters: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('搜索用户失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 搜索动态
  static Future<List<Map<String, dynamic>>> searchPosts({
    required String keyword,
    int page = 0,
    int size = 20,
    String? gameType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'keyword': keyword,
        'page': page,
        'size': size,
      };
      
      if (gameType != null) queryParams['gameType'] = gameType;
      
      final response = await _dio.get('/search/posts', queryParameters: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('搜索动态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取热门搜索关键词
  static Future<List<String>> getHotKeywords() async {
    try {
      final response = await _dio.get('/search/hot-keywords');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.cast<String>();
      } else {
        throw Exception('获取热门关键词失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取搜索历史
  static Future<List<String>> getSearchHistory() async {
    try {
      final response = await _dio.get('/search/history');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.cast<String>();
      } else {
        throw Exception('获取搜索历史失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 添加搜索历史
  static Future<void> addSearchHistory(String keyword) async {
    try {
      final response = await _dio.post('/search/history', data: {
        'keyword': keyword,
      });
      
      if (response.data['success'] != true) {
        throw Exception('添加搜索历史失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 清除搜索历史
  static Future<void> clearSearchHistory() async {
    try {
      final response = await _dio.delete('/search/history');
      
      if (response.data['success'] != true) {
        throw Exception('清除搜索历史失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取搜索建议
  static Future<List<String>> getSearchSuggestions(String keyword) async {
    try {
      final response = await _dio.get('/search/suggestions', queryParameters: {
        'keyword': keyword,
      });
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.cast<String>();
      } else {
        throw Exception('获取搜索建议失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取筛选选项
  static Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      final response = await _dio.get('/search/filter-options');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('获取筛选选项失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }
}