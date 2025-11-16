import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../utils/time_utils.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
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
                      : AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        TimeUtils.formatRelativeTime(post.createTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.gameName != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.gameName ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),

            // 动态内容
            if (post.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(post.content, style: theme.textTheme.bodyLarge),
              ),

            // 图片
            if (post.images.isNotEmpty) _buildImages(post.images),

            // 互动按钮
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInteractionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likeCount}',
                    color: post.isLiked
                        ? Colors.red
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    onPressed: onLike,
                    context: context,
                  ),
                  _buildInteractionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentCount}',
                    onPressed: onComment,
                    context: context,
                  ),
                  _buildInteractionButton(
                    icon: Icons.share,
                    label: '分享',
                    onPressed: onShare,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages(List<String> imageUrls) {
    if (imageUrls.length == 1) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(imageUrls.first),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (imageUrls.length == 2) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 120,
              margin: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrls[0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 120,
              margin: EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrls[1]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}
