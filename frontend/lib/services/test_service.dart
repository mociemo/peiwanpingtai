import 'package:dio/dio.dart';
import 'api_service.dart';
import 'mock_service.dart';

class TestService {
  static final Dio _dio = ApiService.dio;
  static bool _useMock = false; // 设置为false使用真实本地API

  /// 测试API连接
  static Future<Map<String, dynamic>> testConnection() async {
    if (_useMock) {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));
      return MockService.mockHealthResponse();
    }

    try {
      final response = await _dio.get('/api/test/health');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('测试连接失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('测试连接失败: $e');
    }
  }

  /// 测试Hello API
  static Future<Map<String, dynamic>> testHello() async {
    if (_useMock) {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));
      return MockService.mockHelloResponse();
    }

    try {
      final response = await _dio.get('/api/test/hello');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('测试Hello失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('测试Hello失败: $e');
    }
  }

  /// 切换模拟模式
  static void setMockMode(bool useMock) {
    _useMock = useMock;
  }

  /// 获取当前模式
  static bool get isMockMode => _useMock;
}