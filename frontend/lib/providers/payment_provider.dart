import 'package:flutter/foundation.dart';
import '../models/recharge_order_model.dart';
import '../services/payment_service.dart';

/// 支付状态管理
class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  // 充值订单列表
  List<RechargeOrder> _rechargeOrders = [];
  List<RechargeOrder> get rechargeOrders => _rechargeOrders;

  // 当前充值订单
  RechargeOrder? _currentOrder;
  RechargeOrder? get currentOrder => _currentOrder;

  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 充值优惠列表
  List<Map<String, dynamic>> _discounts = [];
  List<Map<String, dynamic>> get discounts => _discounts;

  // 分页信息
  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  final int _pageSize = 20;

  /// 创建充值订单
  Future<bool> createRechargeOrder({
    required double amount,
    required String paymentMethod,
    String? discountId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentOrder = await _paymentService.createRechargeOrder(
        amount: amount,
        paymentMethod: paymentMethod,
        discountId: discountId,
      );

      // 将新订单添加到列表开头
      _rechargeOrders.insert(0, _currentOrder!);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 获取充值订单详情
  Future<bool> getRechargeOrderDetail(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentOrder = await _paymentService.getRechargeOrderDetail(orderId);

      // 更新列表中的订单
      final index = _rechargeOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _rechargeOrders[index] = _currentOrder!;
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 获取充值记录列表
  Future<bool> getRechargeOrders({bool refresh = false, String? status}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _rechargeOrders = [];
    }

    if (!_hasMore) return false;

    _setLoading(true);
    _clearError();

    try {
      final orders = await _paymentService.getRechargeOrders(
        page: _currentPage,
        size: _pageSize,
        status: status,
      );

      if (orders.length < _pageSize) {
        _hasMore = false;
      }

      if (refresh) {
        _rechargeOrders = orders;
      } else {
        _rechargeOrders.addAll(orders);
      }

      _currentPage++;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 取消充值订单
  Future<bool> cancelRechargeOrder(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _paymentService.cancelRechargeOrder(orderId);

      if (success) {
        // 更新本地订单状态
        final index = _rechargeOrders.indexWhere(
          (order) => order.id == orderId,
        );
        if (index != -1) {
          _rechargeOrders[index] = _rechargeOrders[index].copyWith(
            status: 'cancelled',
          );
        }

        if (_currentOrder?.id == orderId) {
          _currentOrder = _currentOrder!.copyWith(status: 'cancelled');
        }
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 获取支付参数
  Future<Map<String, dynamic>?> getPaymentParams(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      final params = await _paymentService.getPaymentParams(orderId);
      _setLoading(false);
      notifyListeners();
      return params;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  /// 获取充值优惠列表
  Future<bool> getRechargeDiscounts() async {
    _setLoading(true);
    _clearError();

    try {
      _discounts = await _paymentService.getRechargeDiscounts();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 验证优惠券
  Future<Map<String, dynamic>?> validateDiscount(
    String discountId,
    double amount,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paymentService.validateDiscount(discountId, amount);
      _setLoading(false);
      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  /// 更新订单状态（用于支付回调后更新状态）
  void updateOrderStatus(String orderId, String status) {
    final index = _rechargeOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _rechargeOrders[index] = _rechargeOrders[index].copyWith(
        status: status,
        payTime: status == 'paid' ? DateTime.now() : null,
      );
    }

    if (_currentOrder?.id == orderId) {
      _currentOrder = _currentOrder!.copyWith(
        status: status,
        payTime: status == 'paid' ? DateTime.now() : null,
      );
    }

    notifyListeners();
  }

  /// 清除当前订单
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
  }

  /// 清除错误信息
  void _clearError() {
    _errorMessage = null;
  }
}
