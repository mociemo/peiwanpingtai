import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGame = '';
  double _minPrice = 0;
  double _maxPrice = 100;
  double _minRating = 0;
  
  final List<String> _games = [
    '王者荣耀', '和平精英', '英雄联盟', '原神', 'CS:GO', 
    'DOTA2', '守望先锋', '永劫无间', '穿越火线', '其他'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索陪玩达人'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索游戏或陪玩达人...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (value) => _performSearch(),
            ),
          ),
          
          // 筛选条件
          ExpansionTile(
            title: const Text('筛选条件'),
            initiallyExpanded: true,
            children: [
              // 游戏选择
              _buildFilterSection('游戏类型', _buildGameFilter()),
              
              // 价格范围
              _buildFilterSection('价格范围', _buildPriceFilter()),
              
              // 评分要求
              _buildFilterSection('最低评分', _buildRatingFilter()),
              
              // 筛选按钮
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        child: const Text('重置'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _performSearch,
                        child: const Text('应用筛选'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 搜索结果
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
  
  Widget _buildGameFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _games.map((game) {
        final isSelected = _selectedGame == game;
        return FilterChip(
          label: Text(game),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedGame = selected ? game : '';
            });
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildPriceFilter() {
    return Column(
      children: [
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 100,
          divisions: 10,
          labels: RangeLabels(
            '¥${_minPrice.toInt()}',
            '¥${_maxPrice.toInt()}',
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('¥${_minPrice.toInt()}'),
            Text('¥${_maxPrice.toInt()}'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRatingFilter() {
    return Column(
      children: [
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: _minRating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0星'),
            Text('${_minRating.toStringAsFixed(1)}星'),
            const Text('5星'),
          ],
        ),
      ],
    );
  }
  
  void _resetFilters() {
    setState(() {
      _selectedGame = '';
      _minPrice = 0;
      _maxPrice = 100;
      _minRating = 0;
      _searchController.clear();
    });
    _performSearch();
  }
  
  void _performSearch() {
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '王者荣耀大神 ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '王者荣耀 | 评分: 4.9 | 128单',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥30/小时',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: const Text('立即下单'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}