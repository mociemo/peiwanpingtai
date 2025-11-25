import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_category.dart';
import '../config/api_config.dart';
import '../utils/storage_utils.dart';

class GameCategoryService {
  static const String _baseUrl = ApiConfig.baseUrl;
  
  static Future<List<GameCategory>> getActiveCategories() async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/game-categories'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson.map((json) => GameCategory.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load game categories');
    } catch (e) {
      throw Exception('获取游戏分类失败: $e');
    }
  }

  static Future<GameCategory?> getCategoryById(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/game-categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return GameCategory.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('获取游戏分类详情失败: $e');
    }
  }

  static Future<List<GameCategory>> getCategoriesByStatus(String status) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/game-categories/status/$status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson.map((json) => GameCategory.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load game categories by status');
    } catch (e) {
      throw Exception('按状态获取游戏分类失败: $e');
    }
  }

  static Future<GameCategory> createCategory(GameCategory category) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/game-categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(category.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return GameCategory.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create game category');
    } catch (e) {
      throw Exception('创建游戏分类失败: $e');
    }
  }

  static Future<GameCategory> updateCategory(int id, GameCategory category) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/game-categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(category.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return GameCategory.fromJson(data['data']);
        }
      }
      throw Exception('Failed to update game category');
    } catch (e) {
      throw Exception('更新游戏分类失败: $e');
    }
  }

  static Future<bool> deleteCategory(int id) async {
    try {
      final token = await StorageUtils.getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/game-categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('删除游戏分类失败: $e');
    }
  }
}