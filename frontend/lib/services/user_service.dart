import 'package:dio/dio.dart';
import 'api_service.dart';

class UserService {
  static final Dio _dio = ApiService.dio;

  /// 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('获取用户信息失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新用户信息
  static Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/users/profile', data: userData);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('更新用户信息失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 上传头像
  static Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post('/users/avatar', data: formData);
      
      if (response.data['success'] == true) {
        return response.data['data']['url'];
      } else {
        throw Exception('上传头像失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取用户列表
  static Future<List<Map<String, dynamic>>> getUserList({
    int page = 0,
    int size = 20,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      
      final response = await _dio.get('/users', queryParameters: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('获取用户列表失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 搜索用户
  static Future<List<Map<String, dynamic>>> searchUsers(String keyword) async {
    try {
      final response = await _dio.get('/users/search', queryParameters: {
        'keyword': keyword,
      });
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('搜索用户失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取当前用户信息
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('获取当前用户信息失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新用户状态
  static Future<void> updateUserStatus(String status) async {
    try {
      final response = await _dio.put('/users/status', data: {
        'status': status,
      });
      
      if (response.data['success'] != true) {
        throw Exception('更新用户状态失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 删除用户账户
  static Future<void> deleteAccount() async {
    try {
      final response = await _dio.delete('/users/account');
      
      if (response.data['success'] != true) {
        throw Exception('删除账户失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 创建玩家档案
  static Future<Map<String, dynamic>> createPlayerProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.post('/users/player-profile', data: profileData);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('创建玩家档案失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新玩家档案
  static Future<Map<String, dynamic>> updatePlayerProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put('/users/player-profile', data: profileData);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('更新玩家档案失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新个人资料
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put('/users/profile', data: profileData);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('更新个人资料失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }
}