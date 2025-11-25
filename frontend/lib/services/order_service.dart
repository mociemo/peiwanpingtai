import 'package:dio/dio.dart';

import 'api_service.dart';

/// 订单服务
class OrderService {
  static final Dio _dio = ApiService.dio;

  /// 获取用户订单
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final response = await _dio.get('/orders/user');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      throw Exception('获取订单失败: $e');
    }
  }

  /// 创建订单
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/orders', data: orderData);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('创建订单失败');
    } catch (e) {
      throw Exception('创建订单失败: $e');
    }
  }

  /// 取消订单
  static Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _dio.post('/orders/$orderId/cancel', queryParameters: {
        'reason': reason,
      });
    } catch (e) {
      throw Exception('取消订单失败: $e');
    }
  }

  /// 接受订单（陪玩达人）
  static Future<void> acceptOrder(String orderId) async {
    try {
      await _dio.post('/orders/$orderId/accept');
    } catch (e) {
      throw Exception('接单失败: $e');
    }
  }

  /// 开始订单
  static Future<void> startOrder(String orderId) async {
    try {
      await _dio.post('/orders/$orderId/start');
    } catch (e) {
      throw Exception('开始订单失败: $e');
    }
  }

  /// 完成订单
  static Future<void> completeOrder(String orderId) async {
    try {
      await _dio.post('/orders/$orderId/complete');
    } catch (e) {
      throw Exception('完成订单失败: $e');
    }
  }

  /// 获取订单详情
  static Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('获取订单详情失败');
    } catch (e) {
      throw Exception('获取订单详情失败: $e');
    }
  }

  /// 获取所有订单（管理员）
  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final response = await _dio.get('/api/orders');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      throw Exception('获取订单列表失败: $e');
    }
  }

  /// 更新订单状态
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _dio.put('/api/orders/$orderId/status', data: {
        'status': status,
      });
    } catch (e) {
      throw Exception('更新订单状态失败: $e');
    }
  }

  /// 分配游戏大师
  static Future<void> assignGameMaster(String orderId, String gameMasterId) async {
    try {
      await _dio.put('/api/orders/$orderId/assign', data: {
        'gameMasterId': gameMasterId,
      });
    } catch (e) {
      throw Exception('分配游戏大师失败: $e');
    }
  }

  /// 获取订单统计
  static Future<Map<String, dynamic>> getOrderStats(String userId) async {
    try {
      final response = await _dio.get('/api/orders/stats/$userId');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return {};
    } catch (e) {
      throw Exception('获取订单统计失败: $e');
    }
  }
}