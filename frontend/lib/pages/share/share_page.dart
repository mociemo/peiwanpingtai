import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/share_service.dart';
import '../../models/share_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

class SharePage extends StatefulWidget {
  final String shareType;
  final String shareId;
  final String title;
  final String description;
  final String imageUrl;

  const SharePage({
    super.key,
    required this.shareType,
    required this.shareId,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final ShareService _shareService = ShareService();
  ShareResponse? _shareResponse;
  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateShareLink();
  }

  Future<void> _generateShareLink() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final shareRequest = ShareRequest(
        userId: authProvider.userId!,
        shareType: widget.shareType,
        shareId: widget.shareId,
        platform: 'system', // 默认平台
      );

      final shareResponse = await _shareService.generateShareLink(
        authProvider.token!,
        shareRequest,
      );

      setState(() {
        _shareResponse = shareResponse;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('生成分享链接失败: ${e.toString()}')));
      }
    }
  }

  Future<void> _shareToPlatform(String platform) async {
    if (_shareResponse == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 记录分享行为
      final shareRequest = ShareRequest(
        userId: authProvider.userId!,
        shareType: widget.shareType,
        shareId: widget.shareId,
        platform: platform,
      );

      await _shareService.recordShareAction(authProvider.token!, shareRequest);

      // 执行分享
      // 暂时使用剪贴板代替分享功能
      final shareContent =
          '${_shareResponse!.title}\n${_shareResponse!.description}\n${_shareResponse!.shareUrl}';
      await Clipboard.setData(ClipboardData(text: shareContent));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('分享内容已复制到剪贴板')));
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('分享失败: ${e.toString()}')));
      }
    }
  }

  void _copyLink() {
    if (_shareResponse == null) return;

    Clipboard.setData(ClipboardData(text: _shareResponse!.shareUrl));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('链接已复制到剪贴板')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分享')),
      body: _isGenerating
          ? const LoadingWidget()
          : _shareResponse == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '生成分享链接失败',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(text: '重试', onPressed: _generateShareLink),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分享预览
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _shareResponse!.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _shareResponse!.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _shareResponse!.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey.withValues(alpha: 0.3),
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 分享链接
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '分享链接',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _shareResponse!.shareUrl,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _copyLink,
                              icon: const Icon(Icons.copy),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 分享平台
                  const Text(
                    '分享到',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShareButton(
                        icon: Icons.message,
                        label: '微信',
                        color: const Color(0xFF07C160),
                        onPressed: () => _shareToPlatform('wechat'),
                      ),
                      _buildShareButton(
                        icon: Icons.chat,
                        label: 'QQ',
                        color: const Color(0xFF1296DB),
                        onPressed: () => _shareToPlatform('qq'),
                      ),
                      _buildShareButton(
                        icon: Icons.alternate_email,
                        label: '微博',
                        color: const Color(0xFFE6162D),
                        onPressed: () => _shareToPlatform('weibo'),
                      ),
                      _buildShareButton(
                        icon: Icons.more_horiz,
                        label: '更多',
                        color: Colors.grey,
                        onPressed: () => _shareToPlatform('more'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: IconButton(
            onPressed: _isLoading ? null : onPressed,
            icon: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
