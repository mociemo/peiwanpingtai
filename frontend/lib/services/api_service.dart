import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/http_util.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
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
    // 模拟登录 - 用于测试
    await Future.delayed(const Duration(seconds: 1));
    
    // 测试账号：test / 123456
    if (username == 'test' && password == '123456') {
      return {
        'success': true,
        'message': '登录成功',
        'data': {
          'token': 'mock_jwt_token_for_testing',
          'user': {
            'id': 1,
            'username': 'test',
            'nickname': '测试用户',
            'phone': '13800138000',
            'email': 'test@example.com',
            'userType': 'USER'
          }
        }
      };
    } else if (username == 'admin' && password == 'admin123') {
      return {
        'success': true,
        'message': '登录成功',
        'data': {
          'token': 'mock_jwt_token_for_admin',
          'user': {
            'id': 2,
            'username': 'admin',
            'nickname': '管理员',
            'phone': '13900139000',
            'email': 'admin@example.com',
            'userType': 'ADMIN'
          }
        }
      };
    } else {
      throw Exception('用户名或密码错误');
    }
  }

  static Future<Map<String, dynamic>> register(String username, String password, String email, String phone) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception('注册失败: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    // 模拟获取用户信息 - 用于测试
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'success': true,
      'message': '获取用户信息成功',
      'data': {
        'id': 1,
        'username': 'test',
        'nickname': '测试用户',
        'phone': '13800138000',
        'email': 'test@example.com',
        'userType': 'USER',
        'avatar': null,
        'balance': 100.0,
        'createdAt': '2024-01-01T00:00:00Z'
      }
    };
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
    // 模拟创建订单 - 用于测试
    await Future.delayed(const Duration(seconds: 1));
    
    final orderNo = 'PM${DateTime.now().millisecondsSinceEpoch}';
    
    return {
      'success': true,
      'message': '订单创建成功',
      'data': {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'orderNo': orderNo,
        'playerId': orderData['playerId'],
        'playerName': '测试陪玩',
        'playerAvatar': '',
        'amount': 30.0,
        'duration': orderData['duration'],
        'status': 'PENDING',
        'serviceType': orderData['serviceType'],
        'requirements': orderData['requirements'],
        'contactInfo': orderData['contactInfo'],
        'createTime': DateTime.now().toIso8601String(),
        'startTime': null,
        'endTime': null,
        'cancelReason': null,
        'rating': null,
        'comment': null,
        'commentTime': null,
      }
    };
  }

  static Future<Map<String, dynamic>> getUserOrders() async {
    // 模拟获取订单列表 - 用于测试
    await Future.delayed(const Duration(milliseconds: 500));
    
    final orders = [
      {
        'id': '1',
        'orderNo': 'PM202412150001',
        'playerId': '1',
        'playerName': '王者荣耀大神',
        'playerAvatar': '',
        'amount': 30.0,
        'duration': 60,
        'status': 'PENDING',
        'serviceType': 'GAME_GUIDE',
        'requirements': '需要带飞上分，段位钻石以上',
        'contactInfo': '游戏ID: 123456',
        'createTime': '2024-12-15T10:30:00Z',
        'startTime': null,
        'endTime': null,
        'cancelReason': null,
        'rating': null,
        'comment': null,
        'commentTime': null,
      },
      {
        'id': '2',
        'orderNo': 'PM202412140002',
        'playerId': '2',
        'playerName': '和平精英战神',
        'playerAvatar': '',
        'amount': 25.0,
        'duration': 90,
        'status': 'ACCEPTED',
        'serviceType': 'VOICE',
        'requirements': '语音陪玩，需要耐心指导',
        'contactInfo': 'QQ: 123456789',
        'createTime': '2024-12-14T15:20:00Z',
        'startTime': '2024-12-14T16:00:00Z',
        'endTime': null,
        'cancelReason': null,
        'rating': null,
        'comment': null,
        'commentTime': null,
      },
      {
        'id': '3',
        'orderNo': 'PM202412130003',
        'playerId': '3',
        'playerName': '英雄联盟王者',
        'playerAvatar': '',
        'amount': 35.0,
        'duration': 120,
        'status': 'COMPLETED',
        'serviceType': 'GAME_GUIDE',
        'requirements': '需要教学对线技巧',
        'contactInfo': '游戏ID: lolplayer',
        'createTime': '2024-12-13T09:15:00Z',
        'startTime': '2024-12-13T10:00:00Z',
        'endTime': '2024-12-13T12:00:00Z',
        'cancelReason': null,
        'rating': 4.8,
        'comment': '服务很好，技术很强',
        'commentTime': '2024-12-13T12:30:00Z',
      },
      {
        'id': '4',
        'orderNo': 'PM202412120004',
        'playerId': '4',
        'playerName': '原神大佬',
        'playerAvatar': '',
        'amount': 20.0,
        'duration': 60,
        'status': 'CANCELLED',
        'serviceType': 'ENTERTAINMENT',
        'requirements': '帮忙打副本',
        'contactInfo': '游戏ID: genshin',
        'createTime': '2024-12-12T14:00:00Z',
        'startTime': null,
        'endTime': null,
        'cancelReason': '时间冲突',
        'rating': null,
        'comment': null,
        'commentTime': null,
      },
    ];
    
    return {
      'success': true,
      'message': '获取订单列表成功',
      'data': orders,
    };
  }

  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    // 模拟获取订单详情 - 用于测试
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 根据订单ID返回对应的模拟数据
    final orders = {
      '1': {
        'id': '1',
        'orderNo': 'PM202412150001',
        'playerId': '1',
        'playerName': '王者荣耀大神',
        'playerAvatar': '',
        'amount': 30.0,
        'duration': 60,
        'status': 'PENDING',
        'serviceType': 'GAME_GUIDE',
        'requirements': '需要带飞上分，段位钻石以上',
        'contactInfo': '游戏ID: 123456',
        'createTime': '2024-12-15T10:30:00Z',
        'startTime': null,
        'endTime': null,
        'cancelReason': null,
        'rating': null,
        'comment': null,
        'commentTime': null,
      },
      '2': {
        'id': '2',
        'orderNo': 'PM202412140002',
        'playerId': '2',
        'playerName': '和平精英战神',
        'playerAvatar': '',
        'amount': 25.0,
        'duration': 90,
        'status': 'ACCEPTED',
        'serviceType': 'VOICE',
        'requirements': '语音陪玩，需要耐心指导',
        'contactInfo': 'QQ: 123456789',
        'createTime': '2024-12-14T15:20:00Z',
        'startTime': '2024-12-14T16:00:00Z',
        'endTime': null,
        'cancelReason': null,
        'rating': null,
        'comment': null,
        'commentTime': null,
      },
      '3': {
        'id': '3',
        'orderNo': 'PM202412130003',
        'playerId': '3',
        'playerName': '英雄联盟王者',
        'playerAvatar': '',
        'amount': 35.0,
        'duration': 120,
        'status': 'COMPLETED',
        'serviceType': 'GAME_GUIDE',
        'requirements': '需要教学对线技巧',
        'contactInfo': '游戏ID: lolplayer',
        'createTime': '2024-12-13T09:15:00Z',
        'startTime': '2024-12-13T10:00:00Z',
        'endTime': '2024-12-13T12:00:00Z',
        'cancelReason': null,
        'rating': 4.8,
        'comment': '服务很好，技术很强',
        'commentTime': '2024-12-13T12:30:00Z',
      },
      '4': {
        'id': '4',
        'orderNo': 'PM202412120004',
        'playerId': '4',
        'playerName': '原神大佬',
        'playerAvatar': '',
        'amount': 20.0,
        'duration': 60,
        'status': 'CANCELLED',
        'serviceType': 'ENTERTAINMENT',
        'requirements': '帮忙打副本',
        'contactInfo': '游戏ID: genshin',
        'createTime': '2024-12-12T14:00:00Z',
        'startTime': null,
        'endTime': null,
        'cancelReason': '时间冲突',
        'rating': null,
        'comment': null,
        'commentTime': null,
      },
    };
    
    final order = orders[orderId];
    
    if (order == null) {
      throw Exception('订单不存在');
    }
    
    return {
      'success': true,
      'message': '获取订单详情成功',
      'data': order,
    };
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