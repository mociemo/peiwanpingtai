import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/post_card.dart';
import '../orders/orders_page.dart';
import '../chat/conversations_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('陪玩伴侣'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
            },
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      context.push('/notifications');
                    },
                  ),
                  if (chatProvider.totalUnreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          chatProvider.totalUnreadCount > 99 
                              ? '99+' 
                              : chatProvider.totalUnreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [_HomeTab(), _SearchTab(), _MessagesTab(), _OrdersTab(), _ProfileTab()],
      ),
      bottomNavigationBar: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '首页',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: '发现',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.chat_bubble_outline),
                    if (chatProvider.totalUnreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: Stack(
                  children: [
                    Icon(Icons.chat_bubble),
                    if (chatProvider.totalUnreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                label: '消息',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: '订单',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                activeIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎语
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final username = authProvider.userInfo?['username'] ?? '用户';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '你好，$username',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '发现你心仪的陪玩达人',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Color.alphaBlend(
                        Theme.of(context).colorScheme.onSurface.withAlpha(153),
                        Colors.transparent,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 快速筛选
          _buildQuickFilters(context),

          const SizedBox(height: 24),

          // 推荐达人
          _buildRecommendedPlayers(context),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速筛选',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('热门游戏'),
            _buildFilterChip('语音陪玩'),
            _buildFilterChip('视频陪玩'),
            _buildFilterChip('技术指导'),
            _buildFilterChip('娱乐陪玩'),
            _buildFilterChip('段位要求'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
      },
      selected: false,
    );
  }

  Widget _buildRecommendedPlayers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '推荐达人',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 模拟推荐达人列表
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildPlayerCard(context, index);
          },
        ),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context, int index) {
    final players = [
      {
        'name': '王者荣耀大神',
        'game': '王者荣耀',
        'price': '30元/小时',
        'rating': 4.9,
        'orders': 128,
      },
      {
        'name': '和平精英战神',
        'game': '和平精英',
        'price': '25元/小时',
        'rating': 4.8,
        'orders': 95,
      },
      {
        'name': 'LOL钻石玩家',
        'game': '英雄联盟',
        'price': '35元/小时',
        'rating': 4.7,
        'orders': 76,
      },
      {
        'name': '原神资深玩家',
        'game': '原神',
        'price': '20元/小时',
        'rating': 4.9,
        'orders': 112,
      },
      {
        'name': 'CSGO专业选手',
        'game': 'CS:GO',
        'price': '40元/小时',
        'rating': 4.6,
        'orders': 64,
      },
    ];

    final player = players[index % players.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 24,
              backgroundColor: Color.alphaBlend(
                Theme.of(context).colorScheme.primary.withAlpha(26),
                Colors.transparent,
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player['name']?.toString() ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player['game']?.toString() ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Color.alphaBlend(
                        Theme.of(context).colorScheme.onSurface.withAlpha(153),
                        Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        player['rating']?.toString() ?? '0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${player['orders']?.toString() ?? '0'}单',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Color.alphaBlend(
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(153),
                            Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 价格和按钮
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  player['price']?.toString() ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push('/orders/create', extra: player);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  child: const Text('立即下单'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommunityProvider(),
      child: const CommunityTab(),
    );
  }
}

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  late CommunityProvider _communityProvider;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _communityProvider = Provider.of<CommunityProvider>(context, listen: false);
      await _communityProvider.loadPosts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区动态'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              context.push('/community/create');
            },
          ),
        ],
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, communityProvider, child) {
          if (communityProvider.isLoadingPosts && communityProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => communityProvider.loadPosts(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: communityProvider.posts.length + 1,
              itemBuilder: (context, index) {
                if (index == communityProvider.posts.length) {
                  if (communityProvider.hasMorePosts) {
                    if (communityProvider.isLoadingPosts) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      // 触发加载更多
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        communityProvider.loadPosts();
                      });
                      return const SizedBox();
                    }
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          '没有更多动态了',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                }

                final post = communityProvider.posts[index];
                return PostCard(
                  post: post,
                  onLike: () {
                    communityProvider.toggleLike(post.id);
                  },
                  onComment: () {
                    context.push('/community/posts/${post.id}');
                  },
                  onShare: () {
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return const OrdersPage();
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return const ConversationsPage();
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('个人页面'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.go('/profile');
            },
            child: const Text('查看个人资料'),
          ),
        ],
      ),
    );
  }
}
