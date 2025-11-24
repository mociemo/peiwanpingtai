import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';

class AdminContentPage extends StatefulWidget {
  const AdminContentPage({super.key});

  @override
  State<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends State<AdminContentPage> {
  int _selectedTab = 0;
  List<Post> _pendingPosts = [];
  List<Post> _pinnedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final [pendingPosts, pinnedPosts] = await Future.wait([
        PostService.getPendingPosts(),
        PostService.getPinnedPosts(),
      ]);
      
      setState(() {
        _pendingPosts = pendingPosts;
        _pinnedPosts = pinnedPosts;
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
        title: const Text('内容管理'),
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
          _buildTabItem('待审核', 0),
          _buildTabItem('置顶内容', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
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
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildPendingPosts();
      case 1:
        return _buildPinnedPosts();
      default:
        return Container();
    }
  }

  Widget _buildPendingPosts() {
    if (_pendingPosts.isEmpty) {
      return const Center(
        child: Text('暂无待审核内容'),
      );
    }

    return ListView.builder(
      itemCount: _pendingPosts.length,
      itemBuilder: (context, index) {
        final post = _pendingPosts[index];
        return _buildPostCard(post, true);
      },
    );
  }

  Widget _buildPinnedPosts() {
    if (_pinnedPosts.isEmpty) {
      return const Center(
        child: Text('暂无置顶内容'),
      );
    }

    return ListView.builder(
      itemCount: _pinnedPosts.length,
      itemBuilder: (context, index) {
        final post = _pinnedPosts[index];
        return _buildPostCard(post, false);
      },
    );
  }

  Widget _buildPostCard(Post post, bool isPending) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userAvatar.isNotEmpty 
                      ? NetworkImage(post.userAvatar)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(width: 8),
                Text(
                  post.userName.isNotEmpty ? post.userName : '未知用户',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 内容
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 图片预览
            if (post.images.isNotEmpty)
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(post.images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 12),
            
            // 操作按钮
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approvePost(int.parse(post.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('通过'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectPost(int.parse(post.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('拒绝'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _unpinPost(int.parse(post.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('取消置顶'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _approvePost(int postId) async {
    try {
      await PostService.approvePost(postId.toString(), true);
      _loadData(); // 重新加载数据
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('审核通过')),
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

  void _rejectPost(int postId) async {
    try {
      await PostService.rejectPost(postId.toString());
      _loadData(); // 重新加载数据
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已拒绝')),
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

  void _unpinPost(int postId) async {
    try {
      await PostService.unpinPost(postId.toString());
      _loadData(); // 重新加载数据
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消置顶')),
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