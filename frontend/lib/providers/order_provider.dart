import 'package:flutter/material.dart';

import '../services/order_service.dart';

/// 订单状态管理
class OrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _currentOrder;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get orders => _orders;
  Map<String, dynamic>? get currentOrder => _currentOrder;

  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置订单列表
  void setOrders(List<Map<String, dynamic>> orders) {
    _orders = orders;
    notifyListeners();
  }

  /// 添加订单
  void addOrder(Map<String, dynamic> order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  /// 更新订单
  void updateOrder(String orderId, Map<String, dynamic> updates) {
    final index = _orders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      _orders[index] = {..._orders[index], ...updates};
      notifyListeners();
    }
  }

  /// 删除订单
  void removeOrder(String orderId) {
    _orders.removeWhere((order) => order['id'] == orderId);
    notifyListeners();
  }

  /// 设置当前订单
  void setCurrentOrder(Map<String, dynamic>? order) {
    _currentOrder = order;
    notifyListeners();
  }

  /// 获取用户订单
  Future<void> fetchUserOrders(String userId) async {
    setLoading(true);
    try {
      final orders = await OrderService.getUserOrders();
      setOrders(orders);
    } catch (e) {
      debugPrint('获取订单失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 创建订单
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    setLoading(true);
    try {
      final order = await OrderService.createOrder(orderData);
      addOrder(order);
      return true;
    } catch (e) {
      debugPrint('创建订单失败: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// 取消订单
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await OrderService.cancelOrder(orderId, reason);
      updateOrder(orderId, {'status': 'CANCELLED'});
      return true;
    } catch (e) {
      debugPrint('取消订单失败: $e');
      return false;
    }
  }

  /// 接受订单（陪玩达人）
  Future<bool> acceptOrder(String orderId) async {
    try {
      await OrderService.acceptOrder(orderId);
      updateOrder(orderId, {'status': 'ACCEPTED'});
      return true;
    } catch (e) {
      debugPrint('接单失败: $e');
      return false;
    }
  }

  /// 完成订单
  Future<bool> completeOrder(String orderId) async {
    try {
      await OrderService.completeOrder(orderId);
      updateOrder(orderId, {'status': 'COMPLETED'});
      return true;
    } catch (e) {
      debugPrint('完成订单失败: $e');
      return false;
    }
  }

  /// 清空数据
  void clear() {
    _orders.clear();
    _currentOrder = null;
    notifyListeners();
  }
}