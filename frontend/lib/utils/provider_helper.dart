import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/withdrawal_provider.dart';
import '../providers/order_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/community_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/search_provider.dart';

/// Provider辅助工具类，简化Provider获取
class ProviderHelper {
  /// 获取AuthProvider
  static AuthProvider getAuth(BuildContext context, {bool listen = false}) {
    return Provider.of<AuthProvider>(context, listen: listen);
  }

  /// 获取UserProvider
  static UserProvider getUser(BuildContext context, {bool listen = false}) {
    return Provider.of<UserProvider>(context, listen: listen);
  }

  /// 获取PaymentProvider
  static PaymentProvider getPayment(BuildContext context, {bool listen = false}) {
    return Provider.of<PaymentProvider>(context, listen: listen);
  }

  /// 获取BillProvider
  static BillProvider getBill(BuildContext context, {bool listen = false}) {
    return Provider.of<BillProvider>(context, listen: listen);
  }

  /// 获取WithdrawalProvider
  static WithdrawalProvider getWithdrawal(BuildContext context, {bool listen = false}) {
    return Provider.of<WithdrawalProvider>(context, listen: listen);
  }

  /// 获取OrderProvider
  static OrderProvider getOrder(BuildContext context, {bool listen = false}) {
    return Provider.of<OrderProvider>(context, listen: listen);
  }

  /// 获取ChatProvider
  static ChatProvider getChat(BuildContext context, {bool listen = false}) {
    return Provider.of<ChatProvider>(context, listen: listen);
  }

  /// 获取CommunityProvider
  static CommunityProvider getCommunity(BuildContext context, {bool listen = false}) {
    return Provider.of<CommunityProvider>(context, listen: listen);
  }

  /// 获取NotificationProvider
  static NotificationProvider getNotification(BuildContext context, {bool listen = false}) {
    return Provider.of<NotificationProvider>(context, listen: listen);
  }

  /// 获取SearchProvider
  static SearchProvider getSearch(BuildContext context, {bool listen = false}) {
    return Provider.of<SearchProvider>(context, listen: listen);
  }

  /// 获取当前用户ID
  static String getCurrentUserId(BuildContext context) {
    final authProvider = getAuth(context);
    return authProvider.userId ?? 'demo_user';
  }

  /// 获取当前用户信息
  static Map<String, dynamic>? getCurrentUserInfo(BuildContext context) {
    return getAuth(context).userInfo;
  }

  /// 检查用户是否登录
  static bool isUserLoggedIn(BuildContext context) {
    return getAuth(context).isAuthenticated;
  }

  /// 显示SnackBar的便捷方法
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// 显示错误SnackBar的便捷方法
  static void showErrorSnackBar(BuildContext context, String error) {
    showSnackBar(
      context,
      message: error,
      backgroundColor: Colors.red,
    );
  }

  /// 显示成功SnackBar的便捷方法
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
    );
  }
}