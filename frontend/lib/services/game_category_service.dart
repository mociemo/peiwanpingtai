import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/game_category_model.dart';

class GameCategoryService {
  static final Dio _dio = ApiService.dio;

  /// 获取所有游戏分类
  static Future<List<GameCategory>> getAllCategories() async {
    try {
      final response = await _dio.get('/api/game-categories');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson
              .map((json) => GameCategory.fromJson(json))
              .toList();
        }
      }
      throw Exception('获取游戏分类失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取游戏分类失败: $e');
    }
  }

  /// 获取启用的游戏分类
  static Future<List<GameCategory>> getActiveCategories() async {
    try {
      final response = await _dio.get('/api/game-categories/active');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson
              .map((json) => GameCategory.fromJson(json))
              .toList();
        }
      }
      throw Exception('获取启用游戏分类失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取启用游戏分类失败: $e');
    }
  }

  /// 根据ID获取游戏分类
  static Future<GameCategory> getCategoryById(String id) async {
    try {
      final response = await _dio.get('/api/game-categories/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return GameCategory.fromJson(data['data']);
        }
      }
      throw Exception('获取游戏分类详情失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取游戏分类详情失败: $e');
    }
  }

  /// 创建游戏分类（管理员功能）
  static Future<GameCategory> createCategory({
    required String name,
    required String description,
    String? icon,
    int sortOrder = 0,
  }) async {
    try {
      final response = await _dio.post('/api/game-categories', data: {
        'name': name,
        'description': description,
        'icon': icon,
        'sortOrder': sortOrder,
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return GameCategory.fromJson(data['data']);
        }
      }
      throw Exception('创建游戏分类失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('创建游戏分类失败: $e');
    }
  }

  /// 更新游戏分类（管理员功能）
  static Future<GameCategory> updateCategory(
    String id, {
    String? name,
    String? description,
    String? icon,
    int? sortOrder,
    GameCategoryStatus? status,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (icon != null) data['icon'] = icon;
      if (sortOrder != null) data['sortOrder'] = sortOrder;
      if (status != null) data['status'] = status.name;

      final response = await _dio.put('/api/game-categories/$id', data: data);
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return GameCategory.fromJson(responseData['data']);
        }
      }
      throw Exception('更新游戏分类失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('更新游戏分类失败: $e');
    }
  }

  /// 删除游戏分类（管理员功能）
  static Future<bool> deleteCategory(String id) async {
    try {
      final response = await _dio.delete('/api/game-categories/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('删除游戏分类失败: $e');
    }
  }
}