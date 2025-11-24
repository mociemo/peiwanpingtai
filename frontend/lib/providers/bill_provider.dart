import 'package:flutter/foundation.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';

/// 账单状态管理
class BillProvider with ChangeNotifier {
  final BillService _billService = BillService();
  
  // 账单列表
  List<Bill> _bills = [];
  List<Bill> get bills => _bills;
  
  // 当前账单
  Bill? _currentBill;
  Bill? get currentBill => _currentBill;
  
  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // 用户余额
  double _userBalance = 0.0;
  double get userBalance => _userBalance;
  
  // 账单统计信息
  Map<String, dynamic> _billStatistics = {};
  Map<String, dynamic> get billStatistics => _billStatistics;
  
  // 筛选条件
  String? _filterType;
  String? get filterType => _filterType;
  
  DateTime? _filterStartTime;
  DateTime? get filterStartTime => _filterStartTime;
  
  DateTime? _filterEndTime;
  DateTime? get filterEndTime => _filterEndTime;
  
  // 分页信息
  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  
  final int _pageSize = 20;

  /// 获取用户账单列表
  Future<bool> getUserBills({
    bool refresh = false,
    String? type,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _bills = [];
      
      // 更新筛选条件
      _filterType = type;
      _filterStartTime = startTime;
      _filterEndTime = endTime;
    }
    
    if (!_hasMore) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final bills = await _billService.getUserBills(
        page: _currentPage,
        size: _pageSize,
        type: type ?? _filterType,
        startTime: startTime ?? _filterStartTime,
        endTime: endTime ?? _filterEndTime,
      );
      
      if (bills.length < _pageSize) {
        _hasMore = false;
      }
      
      if (refresh) {
        _bills = bills;
      } else {
        _bills.addAll(bills);
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
  
  /// 获取账单详情
  Future<bool> getBillDetail(String billId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentBill = await _billService.getBillDetail(billId);
      
      // 更新列表中的账单
      final index = _bills.indexWhere((bill) => bill.id == billId);
      if (index != -1) {
        _bills[index] = _currentBill!;
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
  
  /// 获取用户余额
  Future<bool> getUserBalance() async {
    _setLoading(true);
    _clearError();
    
    try {
      _userBalance = await _billService.getUserBalance();
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
  
  /// 获取账单统计信息
  Future<bool> getBillStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _billStatistics = await _billService.getBillStatistics(
        startTime: startTime ?? _filterStartTime,
        endTime: endTime ?? _filterEndTime,
      );
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
  
  /// 导出账单数据
  Future<String?> exportBills({
    String? type,
    DateTime? startTime,
    DateTime? endTime,
    String format = 'excel',
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final downloadUrl = await _billService.exportBills(
        type: type ?? _filterType,
        startTime: startTime ?? _filterStartTime,
        endTime: endTime ?? _filterEndTime,
        format: format,
      );
      
      _setLoading(false);
      notifyListeners();
      return downloadUrl;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }
  
  /// 获取达人收益账单
  Future<bool> getEarningBills({
    bool refresh = false,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _bills = [];
      
      // 更新筛选条件
      _filterStartTime = startTime;
      _filterEndTime = endTime;
    }
    
    if (!_hasMore) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final bills = await _billService.getEarningBills(
        page: _currentPage,
        size: _pageSize,
        startTime: startTime ?? _filterStartTime,
        endTime: endTime ?? _filterEndTime,
      );
      
      if (bills.length < _pageSize) {
        _hasMore = false;
      }
      
      if (refresh) {
        _bills = bills;
      } else {
        _bills.addAll(bills);
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
  
  /// 获取平台收支统计（管理员专用）
  Future<bool> getPlatformStatistics({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _billStatistics = await _billService.getPlatformStatistics(
        startTime: startTime,
        endTime: endTime,
      );
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
  
  /// 清除筛选条件
  void clearFilters() {
    _filterType = null;
    _filterStartTime = null;
    _filterEndTime = null;
    notifyListeners();
  }
  
  /// 设置筛选条件
  void setFilters({
    String? type,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    _filterType = type;
    _filterStartTime = startTime;
    _filterEndTime = endTime;
    notifyListeners();
  }
  
  /// 清除当前账单
  void clearCurrentBill() {
    _currentBill = null;
    notifyListeners();
  }
  
  /// 添加新账单（用于实时更新）
  void addBill(Bill bill) {
    _bills.insert(0, bill);
    
    // 更新余额
    _userBalance = bill.balance;
    
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