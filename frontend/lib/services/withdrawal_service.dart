import 'package:dio/dio.dart';

import '../models/withdrawal_application_model.dart';
import '../utils/http_util.dart';

/// 提现服务
class WithdrawalService {
  static final WithdrawalService _instance = WithdrawalService._internal();
  factory WithdrawalService() => _instance;
  WithdrawalService._internal();

  final HttpUtil _httpUtil = HttpUtil();

  /// 创建提现申请
  Future<WithdrawalApplication> createWithdrawalApplication({
    required double amount,
    required String accountType,
    required String accountInfo,
    required String accountName,
  }) async {
    try {
      final response = await _httpUtil.post(
        '/api/withdrawal/apply',
        data: {
          'amount': amount,
          'accountType': accountType,
          'accountInfo': accountInfo,
          'accountName': accountName,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        return data != null ? WithdrawalApplication.fromJson(data) : WithdrawalApplication.empty();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('创建提现申请失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('创建提现申请失败: $e');
    }
  }

  /// 获取提现申请详情
  Future<WithdrawalApplication> getWithdrawalApplicationDetail(String applicationId) async {
    try {
      final response = await _httpUtil.get(
        '/api/withdrawal/$applicationId',
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        return data != null ? WithdrawalApplication.fromJson(data) : WithdrawalApplication.empty();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取提现申请详情失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取提现申请详情失败: $e');
    }
  }

  /// 获取提现记录列表
  Future<List<WithdrawalApplication>> getWithdrawalApplications({
    int page = 1,
    int size = 20,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _httpUtil.get(
        '/api/withdrawal/list',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dataList = response.data?['data']?['list'] as List<dynamic>? ?? [];
        return dataList.map((item) {
          final itemMap = item as Map<String, dynamic>?;
          return itemMap != null ? WithdrawalApplication.fromJson(itemMap) : WithdrawalApplication.empty();
        }).toList();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取提现记录失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取提现记录失败: $e');
    }
  }

  /// 取消提现申请
  Future<bool> cancelWithdrawalApplication(String applicationId) async {
    try {
      final response = await _httpUtil.put(
        '/api/withdrawal/$applicationId/cancel',
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as bool?;
        return data ?? false;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('取消提现申请失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('取消提现申请失败: $e');
    }
  }

  /// 获取用户可提现余额
  Future<double> getAvailableBalance() async {
    try {
      final response = await _httpUtil.get(
        '/api/withdrawal/balance',
      );

      if (response.statusCode == 200) {
        return (response.data?['data'] as num?)?.toDouble() ?? 0.0;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取可提现余额失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取可提现余额失败: $e');
    }
  }

  /// 获取提现规则
  Future<Map<String, dynamic>> getWithdrawalRules() async {
    try {
      final response = await _httpUtil.get(
        '/api/withdrawal/rules',
      );

      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>? ?? {};
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取提现规则失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取提现规则失败: $e');
    }
  }

  /// 计算提现手续费
  Future<double> calculateWithdrawalFee(double amount) async {
    try {
      final response = await _httpUtil.post(
        '/api/withdrawal/fee',
        data: {
          'amount': amount,
        },
      );

      if (response.statusCode == 200) {
        return (response.data?['data'] as num?)?.toDouble() ?? 0.0;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('计算提现手续费失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('计算提现手续费失败: $e');
    }
  }

  /// 获取用户提现账户列表
  Future<List<Map<String, dynamic>>> getUserWithdrawalAccounts() async {
    try {
      final response = await _httpUtil.get(
        '/api/withdrawal/accounts',
      );

      if (response.statusCode == 200) {
        final dataList = response.data?['data'] as List<dynamic>? ?? [];
        return dataList.map((item) {
          final itemMap = item as Map<String, dynamic>?;
          return itemMap ?? {};
        }).toList();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取提现账户失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取提现账户失败: $e');
    }
  }

  /// 添加提现账户
  Future<bool> addWithdrawalAccount({
    required String accountType,
    required String accountInfo,
    required String accountName,
  }) async {
    try {
      final response = await _httpUtil.post(
        '/api/withdrawal/account',
        data: {
          'accountType': accountType,
          'accountInfo': accountInfo,
          'accountName': accountName,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as bool?;
        return data ?? false;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('添加提现账户失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('添加提现账户失败: $e');
    }
  }

  /// 删除提现账户
  Future<bool> deleteWithdrawalAccount(String accountId) async {
    try {
      final response = await _httpUtil.delete(
        '/api/withdrawal/account/$accountId',
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as bool?;
        return data ?? false;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('删除提现账户失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('删除提现账户失败: $e');
    }
  }
}