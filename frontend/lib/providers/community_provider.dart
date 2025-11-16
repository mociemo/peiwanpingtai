import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/follow_model.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';
import '../services/follow_service.dart';

class CommunityProvider with ChangeNotifier {
  // 动态相关状态
  final List<Post> _posts = [];
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;
  int _currentPage = 1;

  // 单个动态状态
  Post? _currentPost;
  bool _isLoadingPostDetail = false;

  // 评论相关状态
  final Map<String, List<Comment>> _postComments = {};
  final Map<String, bool> _isLoadingComments = {};

  // 关注相关状态
  List<FollowRelationship> _followers = [];
  List<FollowRelationship> _following = [];
  bool _isLoadingFollows = false;
  final Map<String, bool> _userFollowStatus = {};

  // Getters
  List<Post> get posts => _posts;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get hasMorePosts => _hasMorePosts;
  Post? get currentPost => _currentPost;
  bool get isLoadingPostDetail => _isLoadingPostDetail;
  List<FollowRelationship> get followers => _followers;
  List<FollowRelationship> get following => _following;
  bool get isLoadingFollows => _isLoadingFollows;

  // 获取动态列表
  Future<void> loadPosts({bool refresh = false}) async {
    if (_isLoadingPosts) return;

    if (refresh) {
      _currentPage = 1;
      _posts.clear();
    }

    _isLoadingPosts = true;
    notifyListeners();

    try {
      final posts = await PostService.getPosts(
        page: _currentPage - 1,
        size: 20,
      );

      _posts.addAll(posts);
      _hasMorePosts = posts.length == 20;
      _currentPage++;
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  // 获取动态详情
  Future<void> loadPostDetail(String postId) async {
    _isLoadingPostDetail = true;
    notifyListeners();

    try {
      _currentPost = await PostService.getPostById(postId);
    } catch (e) {
      debugPrint('Error loading post detail: $e');
    } finally {
      _isLoadingPostDetail = false;
      notifyListeners();
    }
  }

  // 发布动态
  Future<bool> createPost({
    required String content,
    List<String>? images,
    String? video,
  }) async {
    try {
      await PostService.createPost(
        content: content,
        imageUrls: images?.join(','),
        postType: video != null
            ? 'VIDEO'
            : images != null
            ? 'IMAGE'
            : 'TEXT',
      );

      // 发布成功后重新加载第一页
      await loadPosts(refresh: true);
      return true;
    } catch (e) {
      debugPrint('Error creating post: $e');
      return false;
    }
  }

  // 点赞/取消点赞
  Future<bool> toggleLike(String postId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        if (post.isLiked) {
          await PostService.unlikePost(postId);
        } else {
          await PostService.likePost(postId);
        }

        // 更新本地状态
        _posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.likeCount + (post.isLiked ? -1 : 1),
        );
      }

      if (_currentPost?.id == postId) {
        if (_currentPost!.isLiked) {
          await PostService.unlikePost(postId);
        } else {
          await PostService.likePost(postId);
        }

        _currentPost = _currentPost!.copyWith(
          isLiked: !_currentPost!.isLiked,
          likeCount: _currentPost!.likeCount + (_currentPost!.isLiked ? -1 : 1),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling like: $e');
      return false;
    }
  }

  // 获取评论
  Future<void> loadComments(String postId) async {
    _isLoadingComments[postId] = true;
    notifyListeners();

    try {
      final postIdNum = int.tryParse(postId) ?? 0;
      _postComments[postId] = await CommentService.getCommentsByPostId(
        postId: postIdNum,
        size: 20,
      );
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      _isLoadingComments[postId] = false;
      notifyListeners();
    }
  }

  // 发布评论
  Future<bool> createComment(String postId, String content) async {
    try {
      final postIdNum = int.tryParse(postId) ?? 0;
      await CommentService.createComment(postId: postIdNum, content: content);

      // 重新加载评论
      await loadComments(postId);
      return true;
    } catch (e) {
      debugPrint('Error creating comment: $e');
      return false;
    }
  }

  // 关注/取消关注
  Future<bool> toggleFollow(String userId) async {
    try {
      final userIdNum = int.tryParse(userId) ?? 0;
      if (_userFollowStatus[userId] ?? false) {
        await FollowService.unfollowUser(targetUserId: userIdNum);
      } else {
        await FollowService.followUser(targetUserId: userIdNum);
      }

      _userFollowStatus[userId] = !(_userFollowStatus[userId] ?? false);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      return false;
    }
  }

  // 检查关注状态
  bool isFollowing(String userId) {
    return _userFollowStatus[userId] ?? false;
  }

  // 获取关注列表
  Future<void> loadFollows(String type, String userId) async {
    _isLoadingFollows = true;
    notifyListeners();

    try {
      final userIdNum = int.tryParse(userId) ?? 0;
      if (type == 'followers') {
        _followers = await FollowService.getFollowers(userId: userIdNum);
      } else {
        _following = await FollowService.getFollowing(userId: userIdNum);
      }
    } catch (e) {
      debugPrint('Error loading follows: $e');
    } finally {
      _isLoadingFollows = false;
      notifyListeners();
    }
  }

  // 获取评论列表
  List<Comment> getComments(String postId) {
    return _postComments[postId] ?? [];
  }

  // 检查评论是否正在加载
  bool isLoadingComments(String postId) {
    return _isLoadingComments[postId] ?? false;
  }

  // 清除当前动态
  void clearCurrentPost() {
    _currentPost = null;
  }

  // 清除状态
  void clear() {
    _posts.clear();
    _currentPost = null;
    _postComments.clear();
    _followers.clear();
    _following.clear();
    _userFollowStatus.clear();
    _currentPage = 1;
    _hasMorePosts = true;
    notifyListeners();
  }
}
