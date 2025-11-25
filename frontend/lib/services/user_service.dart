import 'package:dio/dio.dart';
import 'api_service.dart';

class UserService {
  static final Dio _dio = ApiService.dio;

  /// 获取当前用户信息
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get('/user/info');
      
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
      final response = await _dio.put('/user/info', data: userData);
      
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
        'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post('/files/upload', data: formData);
      
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
      
      final response = await _dio.get('/search/users', queryParameters: queryParams);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
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
      final response = await _dio.get('/search/users', queryParameters: {
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

  /// 获取指定用户信息（公开信息）
  static Future<Map<String, dynamic>> getPublicUserInfo(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('获取用户信息失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 申请成为陪玩达人
  static Future<Map<String, dynamic>> applyForPlayer({Map<String, dynamic>? requestData}) async {
    try {
      final response = await _dio.post(
        '/user/apply-player',
        data: requestData,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('申请陪玩达人失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 更新个人资料
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put('/user/info', data: profileData);
      
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