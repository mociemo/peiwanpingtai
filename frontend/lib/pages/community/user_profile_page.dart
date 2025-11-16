import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart' hide UserStats;
import '../../models/post_model.dart';
import '../../models/follow_model.dart';
import '../../services/follow_service.dart';
import '../../services/post_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_stats_card.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_widget.dart';
import '../share/share_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _user;
  UserStats? _userStats;
  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;
  int _currentPostPage = 0;
  final int _postPageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserPosts();
  }

  void _sharePost(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SharePage(
          shareType: 'post',
          shareId: post.id,
          title: '精彩动态分享',
          description: post.content.length > 50
              ? '${post.content.substring(0, 50)}...'
              : post.content,
          imageUrl: post.images.isNotEmpty ? post.images[0] : '',
        ),
      ),
    );
  }

  void _shareUserProfile() {
    if (_user == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SharePage(
          shareType: 'user',
          shareId: _user!.id,
          title: '${_user!.nickname}的陪玩名片',
          description: _user!.intro ?? '快来体验专业的陪玩服务',
          imageUrl: _user!.avatar,
        ),
      ),
    );
  }

  Future<void> _loadUserProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final stats = await FollowService.getUserStats(
        userId: int.parse(widget.userId),
      );

      setState(() {
        _userStats = stats as UserStats?;
        _user = User(
          id: widget.userId,
          username: 'user${widget.userId}',
          nickname: '测试用户${widget.userId}',
          avatar: '',
          bio: '这是一个测试用户的简介',
          role: UserRole.user,
          status: UserStatus.active,
          createTime: DateTime.now(),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载用户信息失败: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPosts({bool refresh = false}) async {
    if (_isLoadingPosts) return;

    setState(() {
      _isLoadingPosts = true;
      if (refresh) {
        _currentPostPage = 0;
        _hasMorePosts = true;
      }
    });

    try {
      final newPosts = await PostService.getUserPosts(
        userId: widget.userId,
        page: _currentPostPage,
        size: _postPageSize,
      );

      setState(() {
        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }
        _hasMorePosts = newPosts.length == _postPageSize;
        _currentPostPage++;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载动态失败: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _refreshUserPosts() async {
    await _loadUserPosts(refresh: true);
  }

  void _handleFollowUser() async {
    if (_user == null) return;

    try {
      if (_user!.isFollowing) {
        await FollowService.unfollowUser(
          targetUserId: int.parse(widget.userId),
        );
      } else {
        await FollowService.followUser(targetUserId: int.parse(widget.userId));
      }

      await _loadUserProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: ${e.toString()}')));
    }
  }

  void _handleLikePost(String postId, bool isLiked) async {
    try {
      if (isLiked) {
        await PostService.unlikePost(postId);
      } else {
        await PostService.likePost(postId);
      }

      setState(() {
        final postIndex = _posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final updatedPost = _posts[postIndex].copyWith(
            isLiked: !isLiked,
            likeCount: isLiked
                ? _posts[postIndex].likeCount - 1
                : _posts[postIndex].likeCount + 1,
          );
          _posts[postIndex] = updatedPost;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isCurrentUser =
        userProvider.isLoggedIn && userProvider.user?['id'] == widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人主页'),
        actions: [
          if (!isCurrentUser)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareUserProfile(),
            ),
          if (isCurrentUser)
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                _user != null && _user!.avatar.isNotEmpty
                                ? NetworkImage(_user!.avatar)
                                : const AssetImage(
                                        'assets/images/default_avatar.png',
                                      )
                                      as ImageProvider,
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.nickname ?? '匿名用户',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (_user?.bio != null &&
                                    _user!.bio!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _user!.bio!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (!isCurrentUser && userProvider.isLoggedIn)
                            ElevatedButton(
                              onPressed: _handleFollowUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _user?.isFollowing ?? false
                                    ? Colors.grey.shade300
                                    : Theme.of(context).colorScheme.primary,
                                foregroundColor: _user?.isFollowing ?? false
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                _user?.isFollowing ?? false ? '已关注' : '关注',
                              ),
                            ),
                        ],
                      ),

                      if (_userStats != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: UserStatsCard(stats: _userStats!),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshUserPosts,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '动态 (${_posts.length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),

                        if (_posts.isEmpty && !_isLoadingPosts)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.rss_feed,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '暂无动态',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index < _posts.length) {
                                  final post = _posts[index];
                                  return PostCard(
                                    post: post,
                                    onLike: () =>
                                        _handleLikePost(post.id, post.isLiked),
                                    onComment: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/post_detail',
                                        arguments: {'postId': post.id},
                                      );
                                    },
                                    onShare: () {
                                      _sharePost(post);
                                    },
                                  );
                                } else if (_hasMorePosts) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: LoadingWidget(),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                              childCount:
                                  _posts.length + (_hasMorePosts ? 1 : 0),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
