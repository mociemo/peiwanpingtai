import 'package:flutter/foundation.dart';
import '../models/withdrawal_application_model.dart';
import '../services/withdrawal_service.dart';

/// 提现状态管理
class WithdrawalProvider with ChangeNotifier {
  final WithdrawalService _withdrawalService = WithdrawalService();
  
  // 提现申请列表
  List<WithdrawalApplication> _withdrawalApplications = [];
  List<WithdrawalApplication> get withdrawalApplications => _withdrawalApplications;
  
  // 当前提现申请
  WithdrawalApplication? _currentApplication;
  WithdrawalApplication? get currentApplication => _currentApplication;
  
  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // 可提现余额
  double _availableBalance = 0.0;
  double get availableBalance => _availableBalance;
  
  // 提现规则
  Map<String, dynamic> _withdrawalRules = {};
  Map<String, dynamic> get withdrawalRules => _withdrawalRules;
  
  // 用户提现账户列表
  List<Map<String, dynamic>> _userAccounts = [];
  List<Map<String, dynamic>> get userAccounts => _userAccounts;
  
  // 分页信息
  int _currentPage = 1;
  int get currentPage => _currentPage;
  
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  
  final int _pageSize = 20;

  /// 创建提现申请
  Future<bool> createWithdrawalApplication({
    required double amount,
    required String accountType,
    required String accountInfo,
    required String accountName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentApplication = await _withdrawalService.createWithdrawalApplication(
        amount: amount,
        accountType: accountType,
        accountInfo: accountInfo,
        accountName: accountName,
      );
      
      // 将新申请添加到列表开头
      _withdrawalApplications.insert(0, _currentApplication!);
      
      // 更新可提现余额
      await getAvailableBalance();
      
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
  
  /// 获取提现申请详情
  Future<bool> getWithdrawalApplicationDetail(String applicationId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentApplication = await _withdrawalService.getWithdrawalApplicationDetail(applicationId);
      
      // 更新列表中的申请
      final index = _withdrawalApplications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        _withdrawalApplications[index] = _currentApplication!;
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
  
  /// 获取提现记录列表
  Future<bool> getWithdrawalApplications({
    bool refresh = false,
    String? status,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _withdrawalApplications = [];
    }
    
    if (!_hasMore) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final applications = await _withdrawalService.getWithdrawalApplications(
        page: _currentPage,
        size: _pageSize,
        status: status,
      );
      
      if (applications.length < _pageSize) {
        _hasMore = false;
      }
      
      if (refresh) {
        _withdrawalApplications = applications;
      } else {
        _withdrawalApplications.addAll(applications);
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
  
  /// 取消提现申请
  Future<bool> cancelWithdrawalApplication(String applicationId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _withdrawalService.cancelWithdrawalApplication(applicationId);
      
      if (success) {
        // 更新本地申请状态
        final index = _withdrawalApplications.indexWhere((app) => app.id == applicationId);
        if (index != -1) {
          _withdrawalApplications[index] = _withdrawalApplications[index].copyWith(status: 'cancelled');
        }
        
        if (_currentApplication?.id == applicationId) {
          _currentApplication = _currentApplication!.copyWith(status: 'cancelled');
        }
        
        // 更新可提现余额
        await getAvailableBalance();
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
  
  /// 获取可提现余额
  Future<bool> getAvailableBalance() async {
    _setLoading(true);
    _clearError();
    
    try {
      _availableBalance = await _withdrawalService.getAvailableBalance();
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
  
  /// 获取提现规则
  Future<bool> getWithdrawalRules() async {
    _setLoading(true);
    _clearError();
    
    try {
      _withdrawalRules = await _withdrawalService.getWithdrawalRules();
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
  
  /// 计算提现手续费
  Future<double?> calculateWithdrawalFee(double amount) async {
    _setLoading(true);
    _clearError();
    
    try {
      final fee = await _withdrawalService.calculateWithdrawalFee(amount);
      _setLoading(false);
      notifyListeners();
      return fee;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }
  
  /// 获取用户提现账户列表
  Future<bool> getUserWithdrawalAccounts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _userAccounts = await _withdrawalService.getUserWithdrawalAccounts();
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
  
  /// 添加提现账户
  Future<bool> addWithdrawalAccount({
    required String accountType,
    required String accountInfo,
    required String accountName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _withdrawalService.addWithdrawalAccount(
        accountType: accountType,
        accountInfo: accountInfo,
        accountName: accountName,
      );
      
      if (success) {
        // 刷新账户列表
        await getUserWithdrawalAccounts();
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
  
  /// 删除提现账户
  Future<bool> deleteWithdrawalAccount(String accountId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _withdrawalService.deleteWithdrawalAccount(accountId);
      
      if (success) {
        // 从本地列表中移除
        _userAccounts.removeWhere((account) => account['id'] == accountId);
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
  
  /// 更新申请状态（用于审核后更新状态）
  void updateApplicationStatus(String applicationId, String status, {
    DateTime? processTime,
    String? remark,
  }) {
    final index = _withdrawalApplications.indexWhere((app) => app.id == applicationId);
    if (index != -1) {
      _withdrawalApplications[index] = _withdrawalApplications[index].copyWith(
        status: status,
        processTime: processTime,
        remark: remark,
      );
    }
    
    if (_currentApplication?.id == applicationId) {
      _currentApplication = _currentApplication!.copyWith(
        status: status,
        processTime: processTime,
        remark: remark,
      );
    }
    
    notifyListeners();
  }
  
  /// 清除当前申请
  void clearCurrentApplication() {
    _currentApplication = null;
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