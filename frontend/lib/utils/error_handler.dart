import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'toast_util.dart';

// 模拟 connectivity_plus 功能
class Connectivity {
  static Future<ConnectivityResult> checkConnectivity() async {
    // 这里简化处理，实际应该检查真实网络状态
    return ConnectivityResult.wifi;
  }
}

enum ConnectivityResult {
  none,
  wifi,
  mobile
}

/// 全局错误处理器
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// 处理错误
  static Future<void> handleError(dynamic error, {String? customMessage}) async {
    String message = customMessage ?? '未知错误';

    if (error is DioException) {
      message = _handleDioError(error);
    } else if (error is Exception) {
      message = error.toString().replaceAll('Exception: ', '');
    }

    // 显示错误提示
    ToastUtil.showError(message);
    
    // 记录错误日志
    _logError(error, message);
  }

  /// 处理Dio错误
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络设置';
      case DioExceptionType.sendTimeout:
        return '请求超时，请稍后重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试';
      case DioExceptionType.badResponse:
        return _handleHttpError(error.response?.statusCode ?? 0, error.response?.data);
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badCertificate:
        return '证书验证失败';
      case DioExceptionType.unknown:
        return '网络请求失败，请稍后重试';
    }
  }

  /// 处理HTTP状态码错误
  static String _handleHttpError(int statusCode, dynamic responseData) {
    // 尝试从响应数据中获取错误信息
    String serverMessage = '';
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] ?? '';
    }

    switch (statusCode) {
      case 400:
        return serverMessage.isNotEmpty ? serverMessage : '请求参数错误';
      case 401:
        return '登录已过期，请重新登录';
      case 403:
        return '没有权限访问该资源';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不被允许';
      case 408:
        return '请求超时';
      case 409:
        return serverMessage.isNotEmpty ? serverMessage : '数据冲突';
      case 422:
        return serverMessage.isNotEmpty ? serverMessage : '数据验证失败';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        return serverMessage.isNotEmpty ? serverMessage : '请求失败($statusCode)';
    }
  }

  /// 检查网络连接
  static Future<bool> checkNetworkConnectivity() async {
    try {
      final connectivityResult = await Connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        ToastUtil.showError('网络连接不可用，请检查网络设置');
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 验证响应数据
  static bool validateResponse(dynamic response) {
    if (response == null) {
      ToastUtil.showError('响应数据为空');
      return false;
    }

    if (response is Map<String, dynamic>) {
      final success = response['success'];
      if (success == false) {
        final message = response['message'] ?? '操作失败';
        ToastUtil.showError(message);
        return false;
      }
    }

    return true;
  }

  /// 处理表单验证错误
  static void handleValidationError(Map<String, dynamic> errors) {
    if (errors.isEmpty) return;

    String errorMessage = '';
    errors.forEach((field, messages) {
      if (messages is List) {
        errorMessage += '${messages.join(', ')}\n';
      } else if (messages is String) {
        errorMessage += '$messages\n';
      }
    });

    if (errorMessage.isNotEmpty) {
      ToastUtil.showError(errorMessage.trim());
    }
  }

  /// 处理业务逻辑错误
  static void handleBusinessError(String errorCode, String message) {
    switch (errorCode) {
      case 'USER_NOT_FOUND':
        ToastUtil.showError('用户不存在');
        break;
      case 'INVALID_CREDENTIALS':
        ToastUtil.showError('用户名或密码错误');
        break;
      case 'ACCOUNT_LOCKED':
        ToastUtil.showError('账户已被锁定，请联系客服');
        break;
      case 'INSUFFICIENT_BALANCE':
        ToastUtil.showError('余额不足');
        break;
      case 'ORDER_NOT_FOUND':
        ToastUtil.showError('订单不存在');
        break;
      case 'ORDER_STATUS_INVALID':
        ToastUtil.showError('订单状态不正确');
        break;
      case 'PAYMENT_FAILED':
        ToastUtil.showError('支付失败，请重试');
        break;
      case 'FILE_TOO_LARGE':
        ToastUtil.showError('文件大小超出限制');
        break;
      case 'UNSUPPORTED_FILE_TYPE':
        ToastUtil.showError('不支持的文件类型');
        break;
      case 'RATE_LIMIT_EXCEEDED':
        ToastUtil.showError('操作过于频繁，请稍后重试');
        break;
      default:
        ToastUtil.showError(message);
        break;
    }
  }

  /// 记录错误日志
  static void _logError(dynamic error, String message) {
    bool isDebugMode = true; // 简化处理，实际应该从配置读取
    if (isDebugMode) {
      debugPrint('=== 错误日志 ===');
      debugPrint('时间: ${DateTime.now()}');
      debugPrint('错误类型: ${error.runtimeType}');
      debugPrint('错误信息: $message');
      debugPrint('详细信息: $error');
      debugPrint('==============');
    }

    // 在生产环境中，可以将错误日志发送到服务器
    // _sendErrorToServer(error, message);
  }

  /// 发送错误日志到服务器
  // static Future<void> _sendErrorToServer(dynamic error, String message) async {
  //   try {
  //     // 实现错误日志上报逻辑
  //     // 可以使用专门的错误监控服务，如 Sentry、Firebase Crashlytics 等
  //   } catch (e) {
  //     debugPrint('发送错误日志失败: $e');
  //   }
  // }

  /// 显示友好的错误页面
  static Widget buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
    String? buttonText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '出现了一些问题',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(buttonText ?? '重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示网络错误页面
  static Widget buildNetworkErrorWidget(VoidCallback onRetry) {
    return buildErrorWidget(
      message: '网络连接失败，请检查网络设置后重试',
      onRetry: onRetry,
      buttonText: '重新连接',
    );
  }

  /// 显示空数据页面
  static Widget buildEmptyWidget({
    required String message,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 全局异常捕获
class GlobalExceptionHandler {
  static void initialize() {
    // 捕获Flutter框架的异常
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorHandler.handleError(
        details.exception,
        customMessage: 'Flutter框架错误',
      );
    };

    // 捕获未被处理的异步异常
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   ErrorHandler.handleError(
    //     error,
    //     customMessage: '异步异常',
    //   );
    //   return true;
    // };
  }
}