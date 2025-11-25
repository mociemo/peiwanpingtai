import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/http_util.dart';
import '../config/api_config.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.apiBaseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  static void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // 统一错误处理
        if (e.response?.statusCode == 401) {
          // Token过期，跳转到登录页
          // 这里可以添加全局的登录跳转逻辑
        }
        return handler.next(e);
      },
    ));
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('登录失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? '登录失败');
      } else {
        throw Exception('网络错误，请检查连接');
      }
    }
  }

  static Future<Map<String, dynamic>> register(String username, String password, String? email, String? phone) async {
    try {
      final Map<String, dynamic> requestData = {
        'username': username,
        'password': password,
      };
      
      // 添加可选字段
      if (email != null && email.isNotEmpty) {
        requestData['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        requestData['phone'] = phone;
      }
      
      final response = await _dio.post('/auth/register', data: requestData);
      return response.data;
    } on DioException catch (e) {
      throw Exception('注册失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get('/user/info');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('获取用户信息失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? '获取用户信息失败');
      } else {
        throw Exception('网络错误，请检查连接');
      }
    }
  }

  static Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/user/info', data: userData);
      return response.data;
    } on DioException catch (e) {
      throw Exception('更新用户信息失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // 第三方登录
  static Future<Map<String, dynamic>> thirdPartyLogin(String provider, String token) async {
    try {
      final response = await _dio.post('/auth/third-party', data: {
        'provider': provider,
        'token': token,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception('第三方登录失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // 发送验证码
  static Future<Map<String, dynamic>> sendVerificationCode(String phone) async {
    try {
      final response = await _dio.post('/auth/send-code', data: {
        'phone': phone,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception('发送验证码失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // 验证验证码
  static Future<Map<String, dynamic>> verifyCode(String phone, String code) async {
    try {
      final response = await _dio.post('/auth/verify-code', data: {
        'phone': phone,
        'code': code,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception('验证码验证失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // 订单相关接口
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/orders', data: orderData);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('创建订单失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? '创建订单失败');
      } else {
        throw Exception('网络错误，请检查连接');
      }
    }
  }

  static Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final response = await _dio.get('/orders/user');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('获取订单列表失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? '获取订单列表失败');
      } else {
        throw Exception('网络错误，请检查连接');
      }
    }
  }

  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('获取订单详情失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? '获取订单详情失败');
      } else {
        throw Exception('网络错误，请检查连接');
      }
    }
  }

  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    try {
      final response = await _dio.post('/orders/$orderId/accept');
      return response.data;
    } on DioException catch (e) {
      throw Exception('接单失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  static Future<Map<String, dynamic>> startOrder(String orderId) async {
    try {
      final response = await _dio.post('/orders/$orderId/start');
      return response.data;
    } on DioException catch (e) {
      throw Exception('开始服务失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  static Future<Map<String, dynamic>> completeOrder(String orderId) async {
    try {
      final response = await _dio.post('/orders/$orderId/complete');
      return response.data;
    } on DioException catch (e) {
      throw Exception('完成服务失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId, String reason) async {
    try {
      final response = await _dio.post('/orders/$orderId/cancel', queryParameters: {
        'reason': reason,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception('取消订单失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  static Future<Map<String, dynamic>> rateOrder(String orderId, String rating, String comment) async {
    try {
      final response = await _dio.post('/orders/$orderId/rate', queryParameters: {
        'rating': rating,
        'comment': comment,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception('评价订单失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // 获取Dio实例，供其他服务使用
  static Dio get dio => _dio;
}

/// API服务初始化
void initApiService() {
  // 初始化HTTP工具
  HttpUtil().init();
  // 初始化拦截器
  ApiService._setupInterceptors();
}