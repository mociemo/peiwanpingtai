import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/follow_service.dart';
import '../../models/follow_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';

class FollowListPage extends StatefulWidget {
  final String userId;
  final bool isFollowers;

  const FollowListPage({
    super.key,
    required this.userId,
    required this.isFollowers,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  List<FollowRelationship> _follows = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadFollows();
  }

  Future<void> _loadFollows({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
      }
    });

    try {
      List<FollowRelationship> newFollows;

      if (widget.isFollowers) {
        newFollows = await FollowService.getFollowers(
          userId: int.parse(widget.userId),
          page: _currentPage,
          size: _pageSize,
        );
      } else {
        newFollows = await FollowService.getFollowing(
          userId: int.parse(widget.userId),
          page: _currentPage,
          size: _pageSize,
        );
      }

      setState(() {
        if (refresh) {
          _follows = newFollows;
        } else {
          _follows.addAll(newFollows);
        }
        _hasMore = newFollows.length == _pageSize;
        _currentPage++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载失败: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshFollows() async {
    await _loadFollows(refresh: true);
  }

  void _handleFollowUser(String targetUserId, bool isFollowing) async {
    try {
      if (isFollowing) {
        await FollowService.unfollowUser(targetUserId: int.parse(targetUserId));
      } else {
        await FollowService.followUser(targetUserId: int.parse(targetUserId));
      }

      // 更新本地状态
      setState(() {
        // 根据实际业务逻辑更新状态
        // 这里需要根据API返回的实际状态来更新
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isFollowers ? '粉丝' : '关注')),
      body: RefreshIndicator(
        onRefresh: _refreshFollows,
        child: CustomScrollView(
          slivers: [
            if (_follows.isEmpty && !_isLoading)
              SliverFillRemaining(
                child: EmptyState(
                  icon: widget.isFollowers
                      ? Icons.people_outline
                      : Icons.person_outline,
                  message: widget.isFollowers
                      ? '还没有人关注你，多发布动态吸引粉丝吧！'
                      : '你还没有关注任何人，去发现有趣的人吧！',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index < _follows.length) {
                    final follow = _follows[index];
                    
                    // 根据关注类型确定用户信息
                    final userInfo = widget.isFollowers
                        ? {
                            'id': follow.followerId,
                            'name': follow.followerName,
                            'avatar': follow.followerAvatar,
                            'isFollowing': follow.status == FollowStatus.following,
                          }
                        : {
                            'id': follow.followingId,
                            'name': follow.followingName,
                            'avatar': follow.followingAvatar,
                            'isFollowing': follow.status == FollowStatus.following,
                          };
                    
                    return UserCard(
                      user: userInfo,
                      showFollowButton:
                          userProvider.isLoggedIn &&
                          userProvider.user?['id'] != userInfo['id'],
                      isFollowing: userInfo['isFollowing'] as bool,
                      onFollow: () => _handleFollowUser(
                        userInfo['id'] as String,
                        userInfo['isFollowing'] as bool,
                      ),
                    );
                  } else if (_hasMore) {
                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoadingWidget(),
                    );
                  } else {
                    return Container();
                  }
                }, childCount: _follows.length + (_hasMore ? 1 : 0)),
              ),
          ],
        ),
      ),
    );
  }
}
