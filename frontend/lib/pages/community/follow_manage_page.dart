import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/follow_service.dart';
import '../../models/follow_model.dart';

class FollowManagePage extends StatefulWidget {
  final String userId;
  
  const FollowManagePage({
    super.key,
    required this.userId,
  });

  @override
  State<FollowManagePage> createState() => _FollowManagePageState();
}

class _FollowManagePageState extends State<FollowManagePage> {
  int _selectedTab = 0;
  List<FollowRelationship> _followers = [];
  List<FollowRelationship> _following = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final [followers, following] = await Future.wait([
        FollowService.getFollowers(userId: int.parse(widget.userId)),
        FollowService.getFollowing(userId: int.parse(widget.userId)),
      ]);
      
      setState(() {
        _followers = followers;
        _following = following;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关注管理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 标签页
          _buildTabBar(),
          
          // 内容区域
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildTabItem('粉丝', 0, _followers.length),
          _buildTabItem('关注', 1, _following.length),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, int count) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final users = _selectedTab == 0 ? _followers : _following;
    
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 0 ? Icons.people_outline : Icons.person_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 0 ? '暂无粉丝' : '暂无关注',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user, _selectedTab == 0);
      },
    );
  }

  Widget _buildUserCard(FollowRelationship user, bool isFollower) {
    final displayName = isFollower ? user.followerName : user.followingName;
    final avatar = isFollower ? user.followerAvatar : user.followingAvatar;
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 25,
              backgroundImage: avatar.isNotEmpty 
                  ? NetworkImage(avatar)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
            
            const SizedBox(width: 12),
            
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isNotEmpty ? displayName : '未知用户',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user.timeAgo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // 操作按钮
            if (isFollower)
              _buildFollowerActionButton(user)
            else
              _buildFollowingActionButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowerActionButton(FollowRelationship user) {
    return ElevatedButton(
      onPressed: () => _handleFollowAction(user.followerId),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      child: const Text('回关'),
    );
  }

  Widget _buildFollowingActionButton(FollowRelationship user) {
    return IconButton(
      onPressed: () => _unfollowUser(user.followingId),
      icon: const Icon(Icons.person_remove, color: Colors.red),
      tooltip: '取消关注',
    );
  }

  void _handleFollowAction(String userId) async {
    try {
      await FollowService.followUser(targetUserId: int.parse(userId));
      
      // 重新加载数据
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('关注成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _unfollowUser(String userId) async {
    try {
      await FollowService.unfollowUser(targetUserId: int.parse(userId));
      
      // 重新加载数据
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('取消关注成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
}