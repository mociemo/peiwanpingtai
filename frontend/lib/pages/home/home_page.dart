import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/featured_content_banner.dart';
import '../../widgets/recommended_player_card.dart';
import '../orders/orders_page.dart';
import '../chat/conversations_page.dart';
import '../search/search_page.dart';
import '../../models/home_content_model.dart';
import '../../services/home_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final HomeService _homeService = HomeService();
  List<HomeContent> _featuredContent = [];
  List<RecommendedPlayer> _recommendedPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final featuredContent = await _homeService.getFeaturedContent();
      final recommendedPlayers = await _homeService.getRecommendedPlayers();

      setState(() {
        _featuredContent = featuredContent;
        _recommendedPlayers = recommendedPlayers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载数据失败: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('陪玩伴侣'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
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
        children: [
          _HomeTab(
            featuredContent: _featuredContent,
            recommendedPlayers: _recommendedPlayers,
            isLoading: _isLoading,
          ),
          const _SearchTab(),
          const _MessagesTab(),
          const _OrdersTab(),
          const _ProfileTab(),
        ],
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
  final List<HomeContent> featuredContent;
  final List<RecommendedPlayer> recommendedPlayers;
  final bool isLoading;

  const _HomeTab({
    required this.featuredContent,
    required this.recommendedPlayers,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

          // 置顶内容
          if (featuredContent.isNotEmpty) ...[
            _buildFeaturedContent(context),
            const SizedBox(height: 24),
          ],

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

  Widget _buildFeaturedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '精选内容',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredContent.length,
            itemBuilder: (context, index) {
              final content = featuredContent[index];
              return FeaturedContentBanner(
                title: content.title,
                description: content.description,
                imageUrl: content.imageUrl,
                linkType: content.linkType,
                linkId: content.linkId,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {},
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
            TextButton(onPressed: () {}, child: const Text('查看全部')),
          ],
        ),
        const SizedBox(height: 12),

        // 推荐达人列表
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendedPlayers.length > 5
              ? 5
              : recommendedPlayers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final player = recommendedPlayers[index];
            return RecommendedPlayerCard(
              id: player.id,
              name: player.nickname,
              avatar: player.avatar,
              rating: player.rating,
              gameTypes: player.gameTypes,
              price: player.price,
              intro: player.intro,
            );
          },
        ),
      ],
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
      _communityProvider = Provider.of<CommunityProvider>(
        context,
        listen: false,
      );
      await _communityProvider.loadPosts(refresh: true);
    }
  }

  void _sharePost(dynamic post, BuildContext context) {
    // 导航到分享页面
    context.push(
      '/share',
      extra: {
        'shareType': 'post',
        'shareId': post.id,
        'title': '精彩动态分享',
        'description': post.content.length > 50
            ? '${post.content.substring(0, 50)}...'
            : post.content,
        'imageUrl': post.images.isNotEmpty ? post.images[0] : '',
      },
    );
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
          if (communityProvider.isLoadingPosts &&
              communityProvider.posts.isEmpty) {
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
                    _sharePost(post, context);
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
          const Text('个人页面 - 开发中'),
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
