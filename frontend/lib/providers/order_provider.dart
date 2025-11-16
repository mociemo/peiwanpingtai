import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      final response = await ApiService.getUserOrders();
      if (response['success'] == true) {
        final List<dynamic> ordersData = response['data'];
        _orders = ordersData.map((orderData) => Order.fromJson(orderData)).toList();
        _error = null;
      } else {
        _error = response['message'] ?? '获取订单列表失败';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await ApiService.getOrderById(orderId);
      if (response['success'] == true) {
        return Order.fromJson(response['data']);
      } else {
        _error = response['message'] ?? '获取订单详情失败';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
  
  Future<void> createOrder(Order order) async {
    _setLoading(true);
    try {
      final orderData = order.toJson();
      final response = await ApiService.createOrder(orderData);
      if (response['success'] == true) {
        await fetchOrders(); // 刷新订单列表
        _error = null;
      } else {
        _error = response['message'] ?? '创建订单失败';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateOrderStatus(String orderId, String status) async {
    _setLoading(true);
    try {
      // 根据状态调用不同的API
      if (status == 'ACCEPTED') {
        final response = await ApiService.acceptOrder(orderId);
        if (response['success'] != true) {
          _error = response['message'] ?? '接受订单失败';
          _setLoading(false);
          return;
        }
      } else if (status == 'COMPLETED') {
        final response = await ApiService.completeOrder(orderId);
        if (response['success'] != true) {
          _error = response['message'] ?? '完成订单失败';
          _setLoading(false);
          return;
        }
      }
      
      await fetchOrders(); // 刷新订单列表
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> cancelOrder(String orderId, {String reason = '用户取消'}) async {
    _setLoading(true);
    try {
      final response = await ApiService.cancelOrder(orderId, reason);
      if (response['success'] == true) {
        await fetchOrders(); // 刷新订单列表
        _error = null;
      } else {
        _error = response['message'] ?? '取消订单失败';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}