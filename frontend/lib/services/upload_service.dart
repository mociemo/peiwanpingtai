import 'package:dio/dio.dart';
import 'api_service.dart';

class UploadService {
  static final Dio _dio = ApiService.dio;

  /// 上传单个文件
  static Future<Map<String, dynamic>> uploadFile(String filePath, {
    String? folder,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (folder != null) 'folder': folder,
      });
      
      final response = await _dio.post(
        '/upload/file',
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('上传文件失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 上传多个文件
  static Future<List<Map<String, dynamic>>> uploadFiles(
    List<String> filePaths, {
    String? folder,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {};
      
      if (folder != null) {
        formDataMap['folder'] = folder;
      }
      
      for (int i = 0; i < filePaths.length; i++) {
        formDataMap['files[$i]'] = await MultipartFile.fromFile(filePaths[i]);
      }
      
      final formData = FormData.fromMap(formDataMap);
      
      final response = await _dio.post(
        '/upload/files',
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('上传文件失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 上传图片（自动压缩）
  static Future<Map<String, dynamic>> uploadImage(
    String filePath, {
    int? maxWidth,
    int? maxHeight,
    int quality = 80,
    String? folder,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (maxWidth != null) 'maxWidth': maxWidth,
        if (maxHeight != null) 'maxHeight': maxHeight,
        'quality': quality,
        if (folder != null) 'folder': folder,
      });
      
      final response = await _dio.post(
        '/upload/image',
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('上传图片失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 上传头像
  static Future<Map<String, dynamic>> uploadAvatar(
    String filePath, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        '/upload/avatar',
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('上传头像失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 上传语音文件
  static Future<Map<String, dynamic>> uploadVoice(
    String filePath, {
    int duration = 0,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'voice': await MultipartFile.fromFile(filePath),
        'duration': duration,
      });
      
      final response = await _dio.post(
        '/upload/voice',
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('上传语音失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 上传视频文件
  static Future<Map<String, dynamic>> uploadVideo(
    String filePath, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        '/upload/video',
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('上传视频失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取上传进度
  static Stream<Map<String, dynamic>> getUploadProgress(String uploadId) async* {
    // 这里可以实现WebSocket或轮询来获取上传进度
    // 暂时返回空实现
    yield* Stream.empty();
  }

  /// 取消上传
  static Future<void> cancelUpload(String uploadId) async {
    try {
      final response = await _dio.delete('/upload/$uploadId');
      
      if (response.data['success'] != true) {
        throw Exception('取消上传失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 获取文件信息
  static Future<Map<String, dynamic>> getFileInfo(String fileId) async {
    try {
      final response = await _dio.get('/upload/info/$fileId');
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('获取文件信息失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  /// 删除文件
  static Future<void> deleteFile(String fileId) async {
    try {
      final response = await _dio.delete('/upload/$fileId');
      
      if (response.data['success'] != true) {
        throw Exception('删除文件失败: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }
}