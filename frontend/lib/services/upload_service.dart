import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_provider.dart';
import '../config/api_config.dart';

/// 文件上传服务
class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  /// 上传图片
  static Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/upload/image'),
      );

      // 添加认证头
      final authProvider = globalAuthProvider;
      if (authProvider?.token != null) {
        request.headers['Authorization'] = 'Bearer ${authProvider!.token}';
      }

      // 添加文件
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final result = _handleHttpResponse(response);
      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception(result['message'] ?? '上传失败');
      }
    } catch (e) {
      debugPrint('图片上传失败: $e');
      return null;
    }
  }

  /// 上传语音
  static Future<Map<String, dynamic>?> uploadVoice(File voiceFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/upload/voice'),
      );

      // 添加认证头
      final authProvider = globalAuthProvider;
      if (authProvider?.token != null) {
        request.headers['Authorization'] = 'Bearer ${authProvider!.token}';
      }

      // 添加文件
      final voiceBytes = await voiceFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        voiceBytes,
        filename: voiceFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final result = _handleHttpResponse(response);
      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception(result['message'] ?? '上传失败');
      }
    } catch (e) {
      debugPrint('语音上传失败: $e');
      return null;
    }
  }

  /// 上传视频
  static Future<Map<String, dynamic>?> uploadVideo(File videoFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/upload/video'),
      );

      // 添加认证头
      final authProvider = globalAuthProvider;
      if (authProvider?.token != null) {
        request.headers['Authorization'] = 'Bearer ${authProvider!.token}';
      }

      // 添加文件
      final videoBytes = await videoFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        videoBytes,
        filename: videoFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final result = _handleHttpResponse(response);
      if (result['success'] == true) {
        return result['data'];
      } else {
        throw Exception(result['message'] ?? '上传失败');
      }
    } catch (e) {
      debugPrint('视频上传失败: $e');
      return null;
    }
  }

  /// 从相机拍照
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _instance._imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }

  /// 从相册选择图片
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _instance._imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('选择图片失败: $e');
      return null;
    }
  }

  /// 从相册选择多张图片
  static Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _instance._imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('选择多张图片失败: $e');
      return [];
    }
  }

  /// 录制视频
  static Future<File?> pickVideoFromCamera() async {
    try {
      final XFile? video = await _instance._imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      return video != null ? File(video.path) : null;
    } catch (e) {
      debugPrint('录制视频失败: $e');
      return null;
    }
  }

  /// 从相册选择视频
  static Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _instance._imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
      return video != null ? File(video.path) : null;
    } catch (e) {
      debugPrint('选择视频失败: $e');
      return null;
    }
  }

  /// 删除文件
  static Future<bool> deleteFile(String fileUrl) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${globalAuthProvider?.token ?? ''}',
        },
        body: jsonEncode({'url': fileUrl}),
      );

      final result = _handleHttpResponse(response);
      return result['success'] == true;
    } catch (e) {
      debugPrint('删除文件失败: $e');
      return false;
    }
  }

  /// 获取文件信息
  static Future<Map<String, dynamic>?> getFileInfo(String fileUrl) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/upload/info?url=$fileUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${globalAuthProvider?.token ?? ''}',
        },
      );

      final result = _handleHttpResponse(response);
      if (result['success'] == true) {
        return result['data'];
      }
      return null;
    } catch (e) {
      debugPrint('获取文件信息失败: $e');
      return null;
    }
  }

  /// 压缩图片
  static Future<File> compressImage(File imageFile, {int quality = 80}) async {
    // 这里可以使用 image 包进行图片压缩
    // 为了简化，直接返回原文件
    return imageFile;
  }

  /// 获取文件大小
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 检查文件类型
  static String getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp3':
      case 'wav':
      case 'amr':
      case 'aac':
        return 'voice';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return 'video';
      default:
        return 'unknown';
    }
  }

  /// 验证文件大小
  static bool isFileSizeValid(int fileSize, {int maxSizeInMB = 50}) {
    return fileSize <= maxSizeInMB * 1024 * 1024;
  }

  /// 验证图片文件
  static bool isValidImageFile(String fileName) {
    final fileType = getFileType(fileName);
    return fileType == 'image';
  }

  /// 验证音频文件
  static bool isValidVoiceFile(String fileName) {
    final fileType = getFileType(fileName);
    return fileType == 'voice';
  }

  /// 验证视频文件
  static bool isValidVideoFile(String fileName) {
    final fileType = getFileType(fileName);
    return fileType == 'video';
  }
  /// 处理HTTP响应
  static Map<String, dynamic> _handleHttpResponse(http.Response response) {
    try {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      return {'success': false, 'message': '响应格式错误'};
    } catch (e) {
      return {'success': false, 'message': '响应解析失败: $e'};
    }
  }
}

// 全局认证提供者引用（需要在main.dart中设置）
AuthProvider? get globalAuthProvider => AuthProvider.globalAuthProvider;