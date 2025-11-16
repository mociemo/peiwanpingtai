import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/loading_widget.dart';

class PostListPage extends StatefulWidget {
  final String? title;
  final bool showAppBar;
  final String? userId;
  final List<String>? followingUserIds;

  const PostListPage({
    super.key,
    this.title,
    this.showAppBar = true,
    this.userId,
    this.followingUserIds,
  });

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final ScrollController _scrollController = ScrollController();
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
      }
    });

    try {
      List<Post> newPosts;
      
      if (widget.userId != null) {
        newPosts = await PostService.getUserPosts(
          userId: widget.userId!,
          page: _currentPage,
          size: _pageSize,
        );
      } else if (widget.followingUserIds != null) {
        newPosts = await PostService.getFollowingPosts(
          userIds: widget.followingUserIds!,
          page: _currentPage,
          size: _pageSize,
        );
      } else {
        newPosts = await PostService.getPosts(
          page: _currentPage,
          size: _pageSize,
        );
      }

      setState(() {
        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }
        _hasMore = newPosts.length == _pageSize;
        _currentPage++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_hasMore || _isLoading) return;
    await _loadPosts();
  }

  Future<void> _refreshPosts() async {
    await _loadPosts(refresh: true);
  }

  void _handleLikePost(String postId, bool isLiked) async {
    try {
      if (isLiked) {
        await PostService.unlikePost(postId);
      } else {
        await PostService.likePost(postId);
      }
      
      // 更新本地状态
      setState(() {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = post.copyWith(
            isLiked: !isLiked,
            likeCount: isLiked ? post.likeCount - 1 : post.likeCount + 1,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title ?? '动态广场'),
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              actions: [
                if (userProvider.isLoggedIn)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      Navigator.pushNamed(context, '/create_post');
                    },
                  ),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (_posts.isEmpty && !_isLoading)
              SliverFillRemaining(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rss_feed, size: 64, color: Theme.of(context).colorScheme.outline),
                    SizedBox(height: 16),
                    Text('暂无动态', style: Theme.of(context).textTheme.headlineSmall),
                    SizedBox(height: 8),
                    Text(
                      widget.userId != null
                          ? '该用户还没有发布任何动态'
                          : widget.followingUserIds != null
                              ? '关注的人还没有发布动态'
                              : '动态广场空空如也',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.userId == null && widget.followingUserIds == null)
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/community/create'),
                          child: Text('发布第一条动态'),
                        ),
                      ),
                  ],
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
                        onLike: () => _handleLikePost(post.id, post.isLiked),
                        onComment: () {
                          Navigator.pushNamed(
                            context,
                            '/community/posts/${post.id}',
                          );
                        },
                        onShare: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('分享功能开发中')),
                          );
                        },
                      );
                    } else if (_hasMore) {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: LoadingWidget(),
                      );
                    } else {
                      return Container();
                    }
                  },
                  childCount: _posts.length + (_hasMore ? 1 : 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}