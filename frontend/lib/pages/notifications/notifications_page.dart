import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedTab = 0;

  final List<String> _tabTitles = ['全部', '订单', '系统', '活动'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知中心'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: _markAllAsRead,
            tooltip: '全部标记为已读',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAll,
            tooltip: '清空通知',
          ),
        ],
      ),
      body: Column(
        children: [
          // 通知类型筛选
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabTitles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedTab == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedTab == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        _tabTitles[index],
                        style: TextStyle(
                          color: _selectedTab == index
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 通知列表
          Expanded(
            child: ListView.builder(
              itemCount: _getNotifications().length,
              itemBuilder: (context, index) {
                final notification = _getNotifications()[index];
                return _buildNotificationItem(notification, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getNotifications() {
    // 模拟通知数据
    return [
      {
        'id': 1,
        'type': 'order',
        'title': '订单状态更新',
        'message': '您的订单 PM202412150001 已被接单',
        'time': '2024-12-15 10:45',
        'read': false,
        'icon': Icons.shopping_bag,
        'color': Colors.blue,
      },
      {
        'id': 2,
        'type': 'system',
        'title': '系统通知',
        'message': '系统维护通知：今晚23:00-24:00进行系统维护',
        'time': '2024-12-14 18:30',
        'read': true,
        'icon': Icons.info,
        'color': Colors.orange,
      },
      {
        'id': 3,
        'type': 'activity',
        'title': '活动通知',
        'message': '新用户专享：首单立减10元！',
        'time': '2024-12-14 09:15',
        'read': true,
        'icon': Icons.local_activity,
        'color': Colors.green,
      },
      {
        'id': 4,
        'type': 'order',
        'title': '订单提醒',
        'message': '您的订单 PM202412130003 已完成，请及时评价',
        'time': '2024-12-13 21:20',
        'read': true,
        'icon': Icons.rate_review,
        'color': Colors.purple,
      },
    ];
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification['read']
            ? null
            : Color.alphaBlend(
                Theme.of(context).colorScheme.primary.withAlpha(10),
                Colors.transparent,
              ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 24,
            ),
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontWeight: notification['read']
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification['message']),
              const SizedBox(height: 4),
              Text(
                notification['time'],
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          trailing: !notification['read']
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            _markAsRead(notification['id']);
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  void _markAsRead(int notificationId) {
    setState(() {});
  }

  void _markAllAsRead() {
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('全部通知已标记为已读')));
  }

  void _deleteNotification(int notificationId) {
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('通知已删除')));
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空通知'),
        content: const Text('确定要清空所有通知吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('所有通知已清空')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'order':
        break;
      case 'system':
        break;
      case 'activity':
        break;
    }
  }
}
