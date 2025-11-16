import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userInfo = authProvider.userInfo ?? {};
          final username = userInfo['username'] ?? '用户';
          final nickname = userInfo['nickname'] ?? username;
          final avatar = userInfo['avatar'];
          final signature = userInfo['signature'] ?? '这个人很懒，什么都没有留下~';

          return ListView(
            children: [
              // 用户信息卡片
              _buildUserInfoCard(
                context,
                username,
                nickname,
                avatar,
                signature,
              ),

              // 统计信息
              _buildStatsSection(),

              // 功能菜单
              _buildMenuSection(context, authProvider),

              // 退出登录
              _buildLogoutSection(context, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    String username,
    String nickname,
    String? avatar,
    String signature,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color.alphaBlend(
                    Theme.of(context).colorScheme.primary.withAlpha(26),
                    Colors.transparent,
                  ),
                  backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@$username',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        signature,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // 编辑按钮
                IconButton(
                  onPressed: () {
                    _showEditProfileDialog(context);
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: '编辑资料',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/orders');
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('我的订单'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/bills');
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('账单查询'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('总订单', '12'),
            _buildStatItem('进行中', '2'),
            _buildStatItem('已完成', '8'),
            _buildStatItem('待评价', '2'),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider) {
    final userInfo = authProvider.userInfo ?? {};
    final userType = userInfo['userType'] ?? 'USER';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            Icons.security,
            '账户安全',
            '修改密码、绑定手机等',
            () => context.push('/security'),
          ),
          _buildMenuItem(
            context,
            Icons.account_balance_wallet,
            '充值',
            '为账户充值',
            () => context.push('/recharge'),
          ),
          _buildMenuItem(
            context,
            Icons.money,
            '提现',
            '提取账户余额',
            () => context.push('/withdrawal'),
          ),
          _buildMenuItem(
            context,
            Icons.receipt_long,
            '账单查询',
            '查看收支明细',
            () => context.push('/bills'),
          ),
          _buildMenuItem(
            context,
            Icons.payment,
            '支付设置',
            '管理支付方式',
            () => context.push('/payment-settings'),
          ),
          _buildMenuItem(
            context,
            Icons.help,
            '帮助中心',
            '常见问题与客服',
            () => context.push('/help'),
          ),
          _buildMenuItem(
            context,
            Icons.feedback,
            '意见反馈',
            '向我们提出建议',
            () => context.push('/feedback'),
          ),

          if (userType == 'USER')
            _buildMenuItem(
              context,
              Icons.person_add,
              '申请成为陪玩达人',
              '开始你的陪玩之旅',
              () => _applyForPlayer(context, authProvider),
            ),

          if (userType == 'PLAYER')
            _buildMenuItem(
              context,
              Icons.work,
              '陪玩达人中心',
              '管理你的陪玩服务',
              () => context.push('/player-center'),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            Theme.of(context).colorScheme.primary.withAlpha(26),
            Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutSection(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, authProvider),
        icon: const Icon(Icons.logout),
        label: const Text('退出登录'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑资料'),
        content: const Text('编辑资料功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _applyForPlayer(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('申请成为陪玩达人'),
        content: const Text('申请陪玩达人功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('申请已提交，等待审核')));
            },
            child: const Text('确定申请'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.logout();
              context.go('/login');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
