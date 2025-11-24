import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  String? _error;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  String? get error => _error;

  /// 获取通知列表
  Future<void> fetchNotifications({String? type}) async {
    _setLoading(true);
    _clearError();

    try {
      final notifications = await NotificationService.getNotifications(type: type);
      _notifications = notifications;
      await _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新通知列表
  Future<void> refreshNotifications({String? type}) async {
    await fetchNotifications(type: type);
  }

  /// 标记通知为已读
  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      
      // 更新本地状态
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        await _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 批量标记为已读
  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      
      // 更新本地状态
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 删除通知
  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      
      // 更新本地状态
      _notifications.removeWhere((n) => n['id'] == notificationId);
      await _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 添加新通知（用于实时推送）
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    if (!notification['isRead']) {
      _unreadCount++;
    }
    notifyListeners();
  }

  /// 清空通知列表
  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  /// 获取未读通知数量
  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await NotificationService.getUnreadCount();
    } catch (e) {
      debugPrint('获取未读数量失败: $e');
    }
  }

  /// 初始化未读数量
  Future<void> initUnreadCount() async {
    await _updateUnreadCount();
    notifyListeners();
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    _error = null;
  }

  /// 根据类型获取通知
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  /// 获取未读通知
  List<Map<String, dynamic>> getUnreadNotifications() {
    return _notifications.where((n) => !n['isRead']).toList();
  }

  /// 获取已读通知
  List<Map<String, dynamic>> getReadNotifications() {
    return _notifications.where((n) => n['isRead']).toList();
  }

  /// 检查是否有未读通知
  bool get hasUnreadNotifications => _unreadCount > 0;

  /// 获取通知类型统计
  Map<String, int> getNotificationTypeStats() {
    final Map<String, int> stats = {};
    for (var notification in _notifications) {
      final type = notification['type'] as String? ?? 'unknown';
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  }
}