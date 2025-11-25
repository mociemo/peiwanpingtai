import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/post_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart'; // 导入User模型

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  CreatePostPageState createState() => CreatePostPageState();
}

class CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _gameController = TextEditingController();
  String _postType = 'TEXT';
  final List<String> _images = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _gameController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入动态内容')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await PostService.createPost(
        content: _contentController.text.trim(),
        imageUrls: _images.isNotEmpty ? _images.join(',') : null,
        postType: _postType,
        gameName: _gameController.text.trim().isNotEmpty
            ? _gameController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('发布成功')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('发布失败: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _addImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty && mounted) {
        // 这里应该上传图片到服务器，现在先用本地路径
        setState(() {
          _images.addAll(images.map((image) => image.path).toList());
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片添加成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片选择失败: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final currentUser = authProvider.userInfo != null ? User.fromJson(authProvider.userInfo!) : null;

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('发布动态')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('请先登录', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('登录后才能发布动态', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('立即登录'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布动态'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitPost,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '发布',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: currentUser != null && currentUser.avatar.isNotEmpty
                      ? NetworkImage(currentUser.avatar)
                      : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                ),
                const SizedBox(width: 12),
                Text(
                  currentUser?.nickname ?? '用户',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 内容输入框
            TextField(
              controller: _contentController,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: '分享你的游戏心得、陪玩经历...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            // 游戏标签
            TextField(
              controller: _gameController,
              decoration: const InputDecoration(
                hintText: '添加游戏标签（可选）',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
                prefixIcon: Icon(Icons.sports_esports),
              ),
            ),
            const SizedBox(height: 16),

            // 图片预览
            if (_images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('已选择图片:', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _images.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imageUrl = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // 操作按钮
            Row(
              children: [
                // 添加图片
                IconButton(
                  onPressed: _addImage,
                  icon: const Icon(Icons.photo_library),
                  tooltip: '添加图片',
                ),

                // 动态类型选择
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('动态类型:', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _postType,
                        onChanged: (value) {
                          setState(() {
                            _postType = value!;
                          });
                        },
                        items: [
                          const DropdownMenuItem(
                            value: 'TEXT',
                            child: Text('文字'),
                          ),
                          const DropdownMenuItem(
                            value: 'IMAGE',
                            child: Text('图文'),
                          ),
                          const DropdownMenuItem(
                            value: 'VIDEO',
                            child: Text('视频'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 提示信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '请遵守社区规范，发布积极健康的内容',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
