import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';
import '../../utils/toast_util.dart';

class PlayerCenterPage extends StatefulWidget {
  const PlayerCenterPage({super.key});

  @override
  State<PlayerCenterPage> createState() => _PlayerCenterState();
}

class _PlayerCenterState extends State<PlayerCenterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PlayerProfile? _playerProfile;
  List<PlayerService> _services = [];
  List<PlayerOrder> _orders = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;
  String _serviceName = '';
  double _servicePrice = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      
      if (userId == null) {
        throw Exception("用户未登录");
      }
      
      // 从API获取真实数据
      final response = await ApiService.dio.get('/players/profile/$userId');
      
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        setState(() {
          _playerProfile = data['profile'];
          _services = List.from(data['services'] ?? []);
          _orders = List.from(data['orders'] ?? []);
          _stats = data['stats'] ?? {};
        });
      } else {
        throw Exception(response.data['message'] ?? '获取数据失败');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('陪玩达人中心'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '我的资料'),
            Tab(text: '服务管理'),
            Tab(text: '订单管理'),
            Tab(text: '数据统计'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(),
                    _buildServicesTab(),
                    _buildOrdersTab(),
                    _buildStatsTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('加载失败: $_error'),
          const SizedBox(height: 16),
          CustomButton(
            text: '重试',
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_playerProfile == null) {
      return const Center(child: Text('暂无资料'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileDetails(),
          const SizedBox(height: 24),
          _buildSkillTags(),
          const SizedBox(height: 24),
          _buildCertificationStatus(),
          const SizedBox(height: 24),
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _playerProfile?.avatar != null
                  ? NetworkImage(_playerProfile!.avatar!)
                  : null,
              child: _playerProfile?.avatar == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _playerProfile?.nickname ?? '未知',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '评分: ${_playerProfile?.rating ?? 0.0} | 接单量: ${_playerProfile?.totalOrders ?? 0}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${_playerProfile?.hourlyRate ?? 0}/小时',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '个人介绍',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_playerProfile?.introduction ?? '暂无介绍'),
            const SizedBox(height: 16),
            const Text(
              '可服务时间',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_playerProfile?.availableTime ?? '暂无时间安排'),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTags() {
    final tags = _playerProfile?.skillTags ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '技能标签',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.blue.shade50,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.verified,
              color: _playerProfile?.isCertified == true ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _playerProfile?.isCertified == true ? '已认证' : '未认证',
                style: TextStyle(
                  color: _playerProfile?.isCertified == true ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_playerProfile?.isCertified != true)
              CustomButton(
                text: '申请认证',
                onPressed: _applyForCertification,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数据统计',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('总收入', '¥${_stats['totalIncome'] ?? '0'}'),
                ),
                Expanded(
                  child: _buildStatItem('总订单', '${_stats['totalOrders'] ?? '0'}单'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('好评率', '${_stats['positiveRate'] ?? '100'}%'),
                ),
                Expanded(
                  child: _buildStatItem('服务时长', '${_stats['serviceHours'] ?? '0'}小时'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的服务',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              CustomButton(
                text: '添加服务',
                onPressed: _addService,
              ),
            ],
          ),
        ),
        Expanded(
          child: _services.isEmpty
              ? const Center(child: Text('暂无服务'))
              : ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return _buildServiceCard(service);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(PlayerService service) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(service.name),
        subtitle: Text('¥${service.price}/小时'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: service.isActive,
              onChanged: (value) => _toggleService(service, value),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editService(service),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: const Text(
            '订单管理',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _orders.isEmpty
              ? const Center(child: Text('暂无订单'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderCard(order);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(PlayerOrder order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('订单 #${order.orderNo}'),
        subtitle: Text('状态: ${order.status} | 金额: ¥${order.amount}'),
        trailing: _buildOrderAction(order),
      ),
    );
  }

  Widget _buildOrderAction(PlayerOrder order) {
    switch (order.status) {
      case 'PENDING':
        return CustomButton(
          text: '接单',
          onPressed: () => _acceptOrder(order),
        );
      case 'ACCEPTED':
        return CustomButton(
          text: '开始服务',
          onPressed: () => _startOrder(order),
        );
      case 'IN_PROGRESS':
        return CustomButton(
          text: '完成服务',
          onPressed: () => _completeOrder(order),
        );
      default:
        return const Text('已完成');
    }
  }

  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
                _buildStatCard('本月收入', '¥0.00', Icons.trending_up),
                const SizedBox(height: 16),
                _buildStatCard('本月接单', '0单', Icons.shopping_bag),
                const SizedBox(height: 16),
                _buildStatCard('平均评分', '0.0', Icons.star),
                const SizedBox(height: 16),
                _buildStatCard('服务时长', '0小时', Icons.access_time),
              ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 功能方法实现
  void _editProfile() {
    // 跳转到编辑资料页面
    Navigator.pushNamed(context, '/profile/edit');
  }

  void _applyForCertification() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 检查用户是否已经是陪玩达人
      if (authProvider.userInfo?['userType'] == 'PLAYER') {
        ToastUtil.showInfo('您已经是陪玩达人了');
        return;
      }
      
      // 调用申请API
      final response = await ApiService.dio.post('/api/user/apply-player');
      
      if (response.statusCode == 200 && response.data['success']) {
        ToastUtil.showSuccess('申请已提交，等待审核');
        
        // 更新用户信息
        final userInfoResponse = await ApiService.getUserInfo();
        if (userInfoResponse['success']) {
          // 触发AuthProvider重新加载
          if (mounted) {
            Provider.of<AuthProvider>(context, listen: false).refreshUserInfo();
          }
        }
        
        // 重新加载数据
        _loadData();
      } else {
        if (mounted) {
          ToastUtil.showError(response.data['message'] ?? '申请失败');
        }
      }
    } catch (e) {
      ToastUtil.showError('申请失败: ${e.toString()}');
    }
  }

  void _addService() {
    // 显示添加服务对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加服务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '服务名称',
                hintText: '例如：王者荣耀陪练',
              ),
              onChanged: (value) {
                _serviceName = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '服务价格',
                hintText: '例如：20元/小时',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _servicePrice = double.tryParse(value) ?? 0.0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (_serviceName.isEmpty || _servicePrice <= 0) {
                ToastUtil.showError('请填写完整的服务信息');
                return;
              }
              
              try {
                final response = await ApiService.dio.post('/players/services', data: {
                  'serviceName': _serviceName,
                  'servicePrice': _servicePrice,
                });
                
                if (response.statusCode == 200 && response.data['success']) {
                  if (mounted) {
                    navigator.pop();
                    ToastUtil.showSuccess('服务添加成功');
                    _loadData(); // 重新加载数据
                  }
                } else {
                  if (mounted) {
                    ToastUtil.showError(response.data['message'] ?? '添加服务失败');
                  }
                }
              } catch (e) {
                if (mounted) {
                  ToastUtil.showError('添加服务失败: $e');
                }
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _editService(PlayerService service) {
    // 显示编辑服务对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑服务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '服务名称',
              ),
              controller: TextEditingController(text: service.name),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '服务价格',
              ),
              controller: TextEditingController(text: service.price.toString()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ToastUtil.showSuccess('服务更新成功');
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  void _toggleService(PlayerService service, bool value) {
    // 实际项目中应调用接口更新状态
    setState(() {
      final index = _services.indexOf(service);
      if (index != -1) {
        _services[index] = PlayerService(
          name: service.name,
          price: service.price,
          isActive: value,
        );
      }
    });
    ToastUtil.showInfo('服务状态已更新');
  }

  void _acceptOrder(PlayerOrder order) async {
    try {
      final response = await ApiService.dio.post('/api/orders/accept/${order.id}');
      if (response.statusCode == 200 && response.data['success']) {
        ToastUtil.showSuccess('接单成功');
        _loadData(); // 重新加载数据
      } else {
        ToastUtil.showError('接单失败');
      }
    } catch (e) {
      ToastUtil.showError('接单失败: ${e.toString()}');
    }
  }

  void _startOrder(PlayerOrder order) async {
    try {
      final response = await ApiService.dio.post('/api/orders/start/${order.id}');
      if (response.statusCode == 200 && response.data['success']) {
        ToastUtil.showSuccess('服务已开始');
        _loadData(); // 重新加载数据
      } else {
        ToastUtil.showError('开始服务失败');
      }
    } catch (e) {
      ToastUtil.showError('开始服务失败: ${e.toString()}');
    }
  }

  void _completeOrder(PlayerOrder order) async {
    try {
      final response = await ApiService.dio.post('/api/orders/complete/${order.id}');
      if (response.statusCode == 200 && response.data['success']) {
        ToastUtil.showSuccess('服务已完成');
        _loadData(); // 重新加载数据
      } else {
        ToastUtil.showError('完成服务失败');
      }
    } catch (e) {
      ToastUtil.showError('完成服务失败: ${e.toString()}');
    }
  }
}

// 数据模型类
class PlayerProfile {
  final String? avatar;
  final String nickname;
  final double rating;
  final int totalOrders;
  final double hourlyRate;
  final String introduction;
  final String availableTime;
  final List<String> skillTags;
  final bool isCertified;

  PlayerProfile({
    this.avatar,
    required this.nickname,
    required this.rating,
    required this.totalOrders,
    required this.hourlyRate,
    required this.introduction,
    required this.availableTime,
    required this.skillTags,
    required this.isCertified,
  });
}

class PlayerService {
  final String name;
  final double price;
  final bool isActive;

  PlayerService({
    required this.name,
    required this.price,
    required this.isActive,
  });

  // 静态方法：获取玩家资料
  static Future<PlayerProfile?> getPlayerProfile(String userId) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 实际项目中应替换为真实接口调用
    return PlayerProfile(
      avatar: "https://picsum.photos/200/200?random=1",
      nickname: "电竞大神",
      rating: 4.9,
      totalOrders: 156,
      hourlyRate: 88.0,
      introduction: "5年职业电竞选手，擅长MOBA类游戏，曾获省级联赛冠军。耐心教学，包教包会！",
      availableTime: "工作日 19:00-23:00，周末 10:00-23:00",
      skillTags: ["英雄联盟", "王者荣耀", "和平精英", "教学指导"],
      isCertified: true,
    );
  }

  // 静态方法：获取玩家服务列表
  static Future<List<PlayerService>> getPlayerServices(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      PlayerService(name: "英雄联盟陪玩", price: 88.0, isActive: true),
      PlayerService(name: "王者荣耀陪玩", price: 78.0, isActive: true),
      PlayerService(name: "和平精英陪玩", price: 68.0, isActive: false),
      PlayerService(name: "游戏教学指导", price: 98.0, isActive: true),
    ];
  }

  // 静态方法：获取玩家订单列表
  static Future<List<PlayerOrder>> getPlayerOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      PlayerOrder(id: "1", orderNo: "ORD20251119001", status: "COMPLETED", amount: 176.0),
      PlayerOrder(id: "2", orderNo: "ORD20251118002", status: "COMPLETED", amount: 88.0),
      PlayerOrder(id: "3", orderNo: "ORD20251117003", status: "IN_PROGRESS", amount: 98.0),
      PlayerOrder(id: "4", orderNo: "ORD20251119004", status: "PENDING", amount: 78.0),
    ];
  }

  // 静态方法：获取玩家统计数据
  static Future<List<PlayerStats>> getPlayerStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      PlayerStats(label: "本月收入", value: "5,680.00"),
      PlayerStats(label: "本月接单", value: "32单"),
      PlayerStats(label: "平均评分", value: "4.9"),
      PlayerStats(label: "服务时长", value: "128小时"),
    ];
  }
}

class PlayerOrder {
  final String id;
  final String orderNo;
  final String status;
  final double amount;

  PlayerOrder({
    required this.id,
    required this.orderNo,
    required this.status,
    required this.amount,
  });
}

class PlayerStats {
  final String label;
  final String value;

  PlayerStats({
    required this.label,
    required this.value,
  });
}