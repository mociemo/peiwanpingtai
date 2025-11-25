import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// HTTP工具类
class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();
  factory HttpUtil() => _instance;
  HttpUtil._internal();

  late Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 在请求发送前做一些处理
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 在响应返回前做一些处理
          return handler.next(response);
        },
        onError: (error, handler) {
          // 在错误发生时做一些处理
          return handler.next(error);
        },
      ),
    );
  }

  /// GET请求
  Future<Response<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST请求
  Future<Response<Map<String, dynamic>>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT请求
  Future<Response<Map<String, dynamic>>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE请求
  Future<Response<Map<String, dynamic>>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 处理响应数据
  static Map<String, dynamic> handleResponse(Response response) {
    try {
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      return {'success': false, 'message': '响应格式错误'};
    } catch (e) {
      return {'success': false, 'message': '响应解析失败: $e'};
    }
  }

  /// 上传文件
  Future<Map<String, dynamic>> uploadFile(
    String path,
    dynamic file, { // 改为 dynamic 以支持不同文件类型
    Map<String, String>? fields,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        ...?fields,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response.data ?? {'success': false, 'message': '上传失败'};
    } catch (e) {
      return {'success': false, 'message': '上传异常: $e'};
    }
  }
}