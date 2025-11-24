import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/wallet_model.dart';

class WalletService {
  static final Dio _dio = ApiService.dio;

  /// 获取用户钱包信息
  static Future<Wallet> getUserWallet(String userId) async {
    try {
      final response = await _dio.get('/api/wallet/user/$userId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return Wallet.fromJson(data['data']);
        }
      }
      throw Exception('获取钱包信息失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取钱包信息失败: $e');
    }
  }

  /// 获取钱包交易记录
  static Future<List<WalletTransaction>> getWalletTransactions({
    required String userId,
    TransactionType? type,
    TransactionStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      if (type != null) queryParams['type'] = type.name;
      if (status != null) queryParams['status'] = status.name;

      final response = await _dio.get(
        '/api/wallet/transactions/user/$userId',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> transactionsJson = data['data'];
          return transactionsJson
              .map((json) => WalletTransaction.fromJson(json))
              .toList();
        }
      }
      throw Exception('获取交易记录失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取交易记录失败: $e');
    }
  }

  /// 获取交易详情
  static Future<WalletTransaction> getTransactionDetail(String transactionId) async {
    try {
      final response = await _dio.get('/api/wallet/transactions/$transactionId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return WalletTransaction.fromJson(data['data']);
        }
      }
      throw Exception('获取交易详情失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取交易详情失败: $e');
    }
  }

  /// 钱包充值
  static Future<WalletTransaction> recharge({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/api/wallet/recharge', data: {
        'userId': userId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'description': description ?? '钱包充值',
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return WalletTransaction.fromJson(data['data']);
        }
      }
      throw Exception('充值失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('充值失败: $e');
    }
  }

  /// 钱包提现
  static Future<WalletTransaction> withdraw({
    required String userId,
    required double amount,
    required String accountType,
    required String accountInfo,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/api/wallet/withdraw', data: {
        'userId': userId,
        'amount': amount,
        'accountType': accountType,
        'accountInfo': accountInfo,
        'description': description ?? '钱包提现',
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return WalletTransaction.fromJson(data['data']);
        }
      }
      throw Exception('提现失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('提现失败: $e');
    }
  }

  /// 钱包支付
  static Future<WalletTransaction> pay({
    required String userId,
    required double amount,
    required String orderId,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/api/wallet/pay', data: {
        'userId': userId,
        'amount': amount,
        'orderId': orderId,
        'description': description ?? '订单支付',
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return WalletTransaction.fromJson(data['data']);
        }
      }
      throw Exception('支付失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('支付失败: $e');
    }
  }

  /// 钱包退款
  static Future<WalletTransaction> refund({
    required String userId,
    required double amount,
    required String orderId,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/api/wallet/refund', data: {
        'userId': userId,
        'amount': amount,
        'orderId': orderId,
        'description': description ?? '订单退款',
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return WalletTransaction.fromJson(data['data']);
        }
      }
      throw Exception('退款失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('退款失败: $e');
    }
  }

  /// 获取钱包余额
  static Future<double> getWalletBalance(String userId) async {
    try {
      final response = await _dio.get('/api/wallet/balance/user/$userId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return (data['data']['balance'] ?? 0.0).toDouble();
        }
      }
      throw Exception('获取钱包余额失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取钱包余额失败: $e');
    }
  }

  /// 获取钱包统计信息
  static Future<Map<String, dynamic>> getWalletStats(String userId) async {
    try {
      final response = await _dio.get('/api/wallet/stats/user/$userId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('获取钱包统计失败');
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('获取钱包统计失败: $e');
    }
  }

  /// 冻结钱包金额
  static Future<bool> freezeAmount({
    required String userId,
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await _dio.post('/api/wallet/freeze', data: {
        'userId': userId,
        'amount': amount,
        'orderId': orderId,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('冻结金额失败: $e');
    }
  }

  /// 解冻钱包金额
  static Future<bool> unfreezeAmount({
    required String userId,
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await _dio.post('/api/wallet/unfreeze', data: {
        'userId': userId,
        'amount': amount,
        'orderId': orderId,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception('网络错误: ${e.message}');
    } catch (e) {
      throw Exception('解冻金额失败: $e');
    }
  }
}