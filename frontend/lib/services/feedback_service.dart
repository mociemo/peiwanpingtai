import 'package:dio/dio.dart';
import 'api_service.dart';

class FeedbackService {
  static final Dio _dio = ApiService.dio;

  /// 提交反馈
  static Future<Map<String, dynamic>> submitFeedback({
    required String type,
    required String content,
    String? contact,
  }) async {
    try {
      final response = await _dio.post('/feedback', data: {
        'type': type,
        'content': content,
        'contact': contact,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw Exception('提交反馈失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  /// 获取反馈历史
  static Future<Map<String, dynamic>> getFeedbackHistory() async {
    try {
      final response = await _dio.get('/feedback/history');
      
      return response.data;
    } on DioException catch (e) {
      throw Exception('获取反馈历史失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }
}