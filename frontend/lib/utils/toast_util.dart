import 'package:flutter/material.dart';

/// Toast工具类
class ToastUtil {
  /// 显示成功提示
  static void showSuccess(String message) {
    _showToast(
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// 显示错误提示
  static void showError(String message) {
    _showToast(
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  /// 显示信息提示
  static void showInfo(String message) {
    _showToast(
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  /// 显示警告提示
  static void showWarning(String message) {
    _showToast(
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  /// 显示普通提示
  static void show(String message) {
    _showToast(
      message,
      backgroundColor: Colors.grey[700]!,
      icon: Icons.info_outline,
    );
  }

  /// 显示Toast
  static void _showToast(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    // 获取当前context
    final context = _getContext();
    if (context == null) return;

    final scaffoldMessenger = scaffoldMessengerKey.currentState ?? ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 获取当前context
  static BuildContext? _getContext() {
    return navigatorKey.currentContext;
  }

  /// 全局导航键
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// 全局ScaffoldMessenger键
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
}