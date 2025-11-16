import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../services/post_service.dart';
import '../../services/comment_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/comment_item.dart';
import '../../widgets/loading_widget.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Post? _post;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = false;
  bool _hasMoreComments = true;
  int _currentCommentPage = 0;
  final int _commentPageSize = 20;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetail() async {
    try {
      final post = await PostService.getPostById(widget.postId);
      if (mounted) {
        setState(() {
          _post = post;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载动态详情失败: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadComments({bool refresh = false}) async {
    if (_isLoadingComments) return;

    setState(() {
      _isLoadingComments = true;
      if (refresh) {
        _currentCommentPage = 0;
        _hasMoreComments = true;
      }
    });

    try {
      final postIdNum = int.tryParse(widget.postId) ?? 0;
      final newComments = await CommentService.getCommentsByPostId(
        postId: postIdNum,
        page: _currentCommentPage,
        size: _commentPageSize,
      );

      setState(() {
        if (refresh) {
          _comments = newComments;
        } else {
          _comments.addAll(newComments);
        }
        _hasMoreComments = newComments.length == _commentPageSize;
        _currentCommentPage++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载评论失败: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('请先登录')));
      }
      return;
    }

    try {
      final postIdNum = int.tryParse(widget.postId) ?? 0;
      final newComment = await CommentService.createComment(
        postId: postIdNum,
        content: _commentController.text.trim(),
      );

      setState(() {
        _comments.insert(0, newComment);
        if (_post != null) {
          _post = _post!.copyWith(commentCount: _post!.commentCount + 1);
        }
      });

      _commentController.clear();

      // 收起键盘
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('评论失败: ${e.toString()}')));
      }
    }
  }

  void _handleLikePost() async {
    if (_post == null) return;

    try {
      if (_post!.isLiked) {
        await PostService.unlikePost(_post!.id);
      } else {
        await PostService.likePost(_post!.id);
      }

      setState(() {
        _post = _post!.copyWith(
          isLiked: !_post!.isLiked,
          likeCount: _post!.isLiked
              ? _post!.likeCount - 1
              : _post!.likeCount + 1,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: ${e.toString()}')));
      }
    }
  }

  void _handleLikeComment(String commentId, bool isLiked) async {
    try {
      final commentIdNum = int.tryParse(commentId) ?? 0;
      if (isLiked) {
        await CommentService.unlikeComment(commentIdNum);
      } else {
        await CommentService.likeComment(commentIdNum);
      }

      setState(() {
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          final comment = _comments[index];
          _comments[index] = comment.copyWith(
            isLiked: !isLiked,
            likeCount: isLiked ? comment.likeCount - 1 : comment.likeCount + 1,
          );
        }
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
    return Scaffold(
      appBar: AppBar(title: Text('动态详情')),
      body: _isLoading
          ? Center(child: LoadingWidget())
          : Column(
              children: [
                // 动态内容
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_post != null)
                          PostCard(
                            post: _post!,
                            onLike: _handleLikePost,
                            onComment: () {}, // 在当前页面，不需要跳转
                            onShare: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('分享功能开发中')),
                              );
                            },
                          ),

                        // 评论列表
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '评论 (${_comments.length})',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16),

                              if (_comments.isEmpty && !_isLoadingComments)
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '暂无评论',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      _comments.length +
                                      (_hasMoreComments ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index < _comments.length) {
                                      final comment = _comments[index];
                                      return CommentItem(
                                        comment: comment,
                                        onLike: () => _handleLikeComment(
                                          comment.id,
                                          comment.isLiked,
                                        ),
                                        onReply: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('回复功能开发中'),
                                            ),
                                          );
                                        },
                                      );
                                    } else if (_hasMoreComments) {
                                      return Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(child: LoadingWidget()),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 评论输入框
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: '写评论...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: _submitComment,
                        icon: Icon(Icons.send),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
