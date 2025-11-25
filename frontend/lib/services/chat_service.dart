import 'package:dio/dio.dart';
import '../models/message_model.dart';
import 'api_service.dart';

class ChatService {
  static final Dio _dio = ApiService.dio;

  // 获取会话列表
  static Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get('/messages/conversations', queryParameters: {
        'page': page,
        'size': size,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 获取会话详情
  static Future<Map<String, dynamic>> getConversationById(String conversationId) async {
    try {
      final response = await _dio.get('/messages/conversations/$conversationId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 创建会话
  static Future<Map<String, dynamic>> createConversation(String participantId) async {
    try {
      final response = await _dio.post('/messages/conversations', data: {
        'participantId': participantId,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 获取消息列表
  static Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int size = 20,
    String? beforeMessageId,
  }) async {
    try {
      final response = await _dio.get('/messages/conversations/$conversationId/messages', queryParameters: {
        'page': page,
        'size': size,
        if (beforeMessageId != null) 'beforeMessageId': beforeMessageId,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 发送文本消息
  static Future<Map<String, dynamic>> sendTextMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final response = await _dio.post('/messages/conversations/$conversationId/messages', data: {
        'type': MessageType.text.name,
        'content': content,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 发送图片消息
  static Future<Map<String, dynamic>> sendImageMessage(
    String conversationId,
    String imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'type': MessageType.image.name,
        'image': await MultipartFile.fromFile(imagePath),
      });
      
      final response = await _dio.post(
        '/messages/conversations/$conversationId/messages',
        data: formData,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 发送语音消息
  static Future<Map<String, dynamic>> sendVoiceMessage(
    String conversationId,
    String voicePath,
    int duration,
  ) async {
    try {
      final formData = FormData.fromMap({
        'type': MessageType.voice.name,
        'voice': await MultipartFile.fromFile(voicePath),
        'duration': duration,
      });
      
      final response = await _dio.post(
        '/messages/conversations/$conversationId/messages',
        data: formData,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 撤回消息
  static Future<Map<String, dynamic>> recallMessage(String messageId) async {
    try {
      final response = await _dio.put('/messages/$messageId/recall');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 删除消息
  static Future<Map<String, dynamic>> deleteMessage(String messageId) async {
    try {
      final response = await _dio.delete('/messages/$messageId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 标记消息为已读
  static Future<Map<String, dynamic>> markMessagesAsRead(String conversationId) async {
    try {
      final response = await _dio.put('/messages/conversations/$conversationId/read');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 清空聊天记录
  static Future<Map<String, dynamic>> clearChatHistory(String conversationId) async {
    try {
      final response = await _dio.delete('/messages/conversations/$conversationId/messages');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 获取未读消息数量
  static Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _dio.get('/messages/unread-count');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 发送位置消息
  static Future<Map<String, dynamic>> sendLocationMessage(
    String conversationId,
    double latitude,
    double longitude,
    String address,
  ) async {
    try {
      final response = await _dio.post('/messages/conversations/$conversationId/messages', data: {
        'type': MessageType.location.name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 搜索用户
  static Future<Map<String, dynamic>> searchUsers(String keyword) async {
    try {
      final response = await _dio.get('/messages/users/search', queryParameters: {
        'keyword': keyword,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 上传文件
  static Future<Map<String, dynamic>> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post('/upload', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static dynamic _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络设置';
        case DioExceptionType.sendTimeout:
          return '请求超时，请稍后重试';
        case DioExceptionType.receiveTimeout:
          return '响应超时，请稍后重试';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            switch (statusCode) {
              case 400:
                return '请求参数错误';
              case 401:
                return '未授权，请重新登录';
              case 403:
                return '没有权限访问该资源';
              case 404:
                return '请求的资源不存在';
              case 500:
                return '服务器内部错误';
              default:
                return '请求失败，错误码：$statusCode';
            }
          }
          return '请求失败';
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.connectionError:
          return '网络连接失败，请检查网络设置';
        case DioExceptionType.badCertificate:
          return '证书验证失败';
        case DioExceptionType.unknown:
          return '未知错误';
      }
    }
    return error.toString();
  }
}