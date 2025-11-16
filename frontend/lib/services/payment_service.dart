import 'package:dio/dio.dart';

import '../models/recharge_order_model.dart';
import '../utils/http_util.dart';

/// 支付服务
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final HttpUtil _httpUtil = HttpUtil();

  /// 创建充值订单
  Future<RechargeOrder> createRechargeOrder({
    required double amount,
    required String paymentMethod,
    String? discountId,
  }) async {
    try {
      final response = await _httpUtil.post(
        '/api/payment/recharge',
        data: {
          'amount': amount,
          'paymentMethod': paymentMethod,
          'discountId': discountId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        if (data != null) {
          return RechargeOrder.fromJson(data);
        } else {
          throw Exception('创建充值订单失败：返回数据为空');
        }
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('创建充值订单失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('创建充值订单失败: $e');
    }
  }

  /// 获取充值订单详情
  Future<RechargeOrder> getRechargeOrderDetail(String orderId) async {
    try {
      final response = await _httpUtil.get('/api/payment/recharge/$orderId');

      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        if (data != null) {
          return RechargeOrder.fromJson(data);
        } else {
          throw Exception('获取充值订单详情失败：返回数据为空');
        }
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取充值订单详情失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取充值订单详情失败: $e');
    }
  }

  /// 获取充值记录列表
  Future<List<RechargeOrder>> getRechargeOrders({
    int page = 1,
    int size = 20,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'size': size};

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _httpUtil.get(
        '/api/payment/recharge/list',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dataList =
            response.data?['data']?['list'] as List<dynamic>? ?? [];
        return dataList.map((item) {
          final itemMap = item as Map<String, dynamic>?;
          return itemMap != null
              ? RechargeOrder.fromJson(itemMap)
              : RechargeOrder.empty();
        }).toList();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取充值记录失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取充值记录失败: $e');
    }
  }

  /// 取消充值订单
  Future<bool> cancelRechargeOrder(String orderId) async {
    try {
      final response = await _httpUtil.put(
        '/api/payment/recharge/$orderId/cancel',
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as bool?;
        return data ?? false;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('取消充值订单失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('取消充值订单失败: $e');
    }
  }

  /// 获取支付参数（用于调用第三方支付）
  Future<Map<String, dynamic>> getPaymentParams(String orderId) async {
    try {
      final response = await _httpUtil.get('/api/payment/params/$orderId');

      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        return data ?? {};
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取支付参数失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取支付参数失败: $e');
    }
  }

  /// 处理支付回调（通常由后端处理，前端不需要直接调用）
  /// 这里仅作为示例，实际应用中回调URL应该配置在后端
  Future<bool> handlePaymentCallback(Map<String, dynamic> callbackData) async {
    try {
      final response = await _httpUtil.post(
        '/api/payment/callback',
        data: callbackData,
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as bool?;
        return data ?? false;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('处理支付回调失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('处理支付回调失败: $e');
    }
  }

  /// 获取充值优惠列表
  Future<List<Map<String, dynamic>>> getRechargeDiscounts() async {
    try {
      final response = await _httpUtil.get('/api/payment/discounts');

      if (response.statusCode == 200) {
        final dataList = response.data?['data'] as List<dynamic>? ?? [];
        return dataList.map((item) {
          final itemMap = item as Map<String, dynamic>?;
          return itemMap ?? {};
        }).toList();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取充值优惠失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取充值优惠失败: $e');
    }
  }

  /// 验证优惠券是否可用
  Future<Map<String, dynamic>> validateDiscount(
    String discountId,
    double amount,
  ) async {
    try {
      final response = await _httpUtil.post(
        '/api/payment/discount/validate',
        data: {'discountId': discountId, 'amount': amount},
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        return data ?? {};
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('验证优惠券失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('验证优惠券失败: $e');
    }
  }
}
