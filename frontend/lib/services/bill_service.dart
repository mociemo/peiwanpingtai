import 'package:dio/dio.dart';

import '../models/bill_model.dart';
import '../utils/http_util.dart';

/// 账单服务
class BillService {
  static final BillService _instance = BillService._internal();
  factory BillService() => _instance;
  BillService._internal();

  final HttpUtil _httpUtil = HttpUtil();

  /// 获取用户账单列表
  Future<List<Bill>> getUserBills({
    int page = 1,
    int size = 20,
    String? type,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      if (type != null) {
        queryParams['type'] = type;
      }
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final response = await _httpUtil.get(
        '/api/bill/list',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dataList = response.data?['data']?['list'] as List<dynamic>? ?? [];
        return dataList.map((item) {
          final itemMap = item as Map<String, dynamic>?;
          return itemMap != null ? Bill.fromJson(itemMap) : Bill.empty();
        }).toList();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取账单列表失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取账单列表失败: $e');
    }
  }

  /// 获取账单详情
  Future<Bill> getBillDetail(String billId) async {
    try {
      final response = await _httpUtil.get(
        '/api/bill/$billId',
      );

      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        return data != null ? Bill.fromJson(data) : Bill.empty();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取账单详情失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取账单详情失败: $e');
    }
  }

  /// 获取用户账户余额
  Future<double> getUserBalance() async {
    try {
      final response = await _httpUtil.get(
        '/api/bill/balance',
      );

      if (response.statusCode == 200) {
        return (response.data?['data'] as num?)?.toDouble() ?? 0.0;
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取账户余额失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取账户余额失败: $e');
    }
  }

  /// 获取账单统计信息
  Future<Map<String, dynamic>> getBillStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final response = await _httpUtil.get(
        '/api/bill/statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>? ?? {};
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取账单统计失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取账单统计失败: $e');
    }
  }

  /// 导出账单数据
  Future<String> exportBills({
    String? type,
    DateTime? startTime,
    DateTime? endTime,
    String format = 'excel', // excel, csv
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'format': format,
      };
      
      if (type != null) {
        queryParams['type'] = type;
      }
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final response = await _httpUtil.get(
        '/api/bill/export',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data?['data']?['downloadUrl'] as String? ?? '';
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('导出账单失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('导出账单失败: $e');
    }
  }

  /// 获取达人收益账单（达人专用）
  Future<List<Bill>> getEarningBills({
    int page = 1,
    int size = 20,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
      };
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final response = await _httpUtil.get(
        '/api/bill/earning',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final dataList = response.data?['data']?['list'] as List<dynamic>? ?? [];
        return dataList.map((item) {
          final itemMap = item as Map<String, dynamic>?;
          return itemMap != null ? Bill.fromJson(itemMap) : Bill.empty();
        }).toList();
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取收益账单失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取收益账单失败: $e');
    }
  }

  /// 获取平台收支统计（管理员专用）
  Future<Map<String, dynamic>> getPlatformStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final response = await _httpUtil.get(
        '/api/bill/platform/statistics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>? ?? {};
      } else {
        final message = response.data?['message'] ?? '未知错误';
        throw Exception('获取平台收支统计失败: $message');
      }
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    } catch (e) {
      throw Exception('获取平台收支统计失败: $e');
    }
  }
}