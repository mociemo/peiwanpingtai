import 'package:flutter/foundation.dart';
import '../services/search_service.dart';

class SearchProvider with ChangeNotifier {
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _hotKeywords = [];
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  Map<String, dynamic> _filterOptions = {};
  
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _currentKeyword = '';
  
  // 筛选参数
  String? _selectedGameType;
  String? _selectedSkillLevel;
  double? _minPrice;
  double? _maxPrice;

  // Getters
  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<String> get hotKeywords => _hotKeywords;
  List<String> get searchHistory => _searchHistory;
  List<String> get searchSuggestions => _searchSuggestions;
  Map<String, dynamic> get filterOptions => _filterOptions;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get currentKeyword => _currentKeyword;
  String? get selectedGameType => _selectedGameType;
  String? get selectedSkillLevel => _selectedSkillLevel;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  /// 搜索用户
  Future<void> searchUsers(String keyword) async {
    _setSearching(true);
    _clearError();
    _currentKeyword = keyword;

    try {
      final results = await SearchService.searchUsers(
        keyword: keyword,
        gameType: _selectedGameType,
        skillLevel: _selectedSkillLevel,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      
      _searchResults = results;
      
      // 添加到搜索历史
      if (keyword.isNotEmpty) {
        await _addToSearchHistory(keyword);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setSearching(false);
    }
  }

  /// 搜索动态
  Future<void> searchPosts(String keyword) async {
    _setSearching(true);
    _clearError();
    _currentKeyword = keyword;

    try {
      final results = await SearchService.searchPosts(
        keyword: keyword,
        gameType: _selectedGameType,
      );
      
      _searchResults = results;
      
      // 添加到搜索历史
      if (keyword.isNotEmpty) {
        await _addToSearchHistory(keyword);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setSearching(false);
    }
  }

  /// 获取热门关键词
  Future<void> fetchHotKeywords() async {
    _setLoading(true);
    _clearError();

    try {
      final keywords = await SearchService.getHotKeywords();
      _hotKeywords = keywords;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 获取搜索历史
  Future<void> fetchSearchHistory() async {
    try {
      final history = await SearchService.getSearchHistory();
      _searchHistory = history;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 获取搜索建议
  Future<void> fetchSearchSuggestions(String keyword) async {
    if (keyword.isEmpty) {
      _searchSuggestions.clear();
      notifyListeners();
      return;
    }

    try {
      final suggestions = await SearchService.getSearchSuggestions(keyword);
      _searchSuggestions = suggestions;
      notifyListeners();
    } catch (e) {
      debugPrint('获取搜索建议失败: $e');
    }
  }

  /// 获取筛选选项
  Future<void> fetchFilterOptions() async {
    try {
      final options = await SearchService.getFilterOptions();
      _filterOptions = options;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 添加到搜索历史
  Future<void> _addToSearchHistory(String keyword) async {
    try {
      await SearchService.addSearchHistory(keyword);
      
      // 更新本地历史记录
      if (!_searchHistory.contains(keyword)) {
        _searchHistory.insert(0, keyword);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('添加搜索历史失败: $e');
    }
  }

  /// 清除搜索历史
  Future<void> clearSearchHistory() async {
    try {
      await SearchService.clearSearchHistory();
      _searchHistory.clear();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 设置筛选条件
  void setFilters({
    String? gameType,
    String? skillLevel,
    double? minPrice,
    double? maxPrice,
  }) {
    _selectedGameType = gameType;
    _selectedSkillLevel = skillLevel;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    notifyListeners();
  }

  /// 清除筛选条件
  void clearFilters() {
    _selectedGameType = null;
    _selectedSkillLevel = null;
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }

  /// 清除搜索结果
  void clearSearchResults() {
    _searchResults.clear();
    _searchSuggestions.clear();
    _currentKeyword = '';
    notifyListeners();
  }

  /// 从历史记录中删除
  void removeFromHistory(String keyword) {
    _searchHistory.remove(keyword);
    notifyListeners();
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置搜索状态
  void _setSearching(bool searching) {
    _isSearching = searching;
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

  /// 检查是否有筛选条件
  bool get hasFilters => 
      _selectedGameType != null || 
      _selectedSkillLevel != null || 
      _minPrice != null || 
      _maxPrice != null;

  /// 获取当前筛选条件描述
  String get filterDescription {
    final parts = <String>[];
    if (_selectedGameType != null) parts.add(_selectedGameType!);
    if (_selectedSkillLevel != null) parts.add(_selectedSkillLevel!);
    if (_minPrice != null && _maxPrice != null) {
      parts.add('¥${_minPrice!.toInt()}-¥${_maxPrice!.toInt()}');
    } else if (_minPrice != null) {
      parts.add('≥¥${_minPrice!.toInt()}');
    } else if (_maxPrice != null) {
      parts.add('≤¥${_maxPrice!.toInt()}');
    }
    return parts.join(' · ');
  }

  /// 初始化数据
  Future<void> initialize() async {
    await Future.wait([
      fetchHotKeywords(),
      fetchSearchHistory(),
      fetchFilterOptions(),
    ]);
  }
}