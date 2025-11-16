import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final Map<String, Object> user;
  final bool showFollowButton;
  final bool isFollowing;
  final VoidCallback onFollow;

  const UserCard({
    super.key,
    required this.user,
    this.showFollowButton = false,
    this.isFollowing = false,
    required this.onFollow,
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
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 24,
              backgroundImage: user['avatar'] != null
                  ? NetworkImage(user['avatar'] as String)
                  : AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
            ),
            SizedBox(width: 12),

            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (user['name'] ?? '匿名用户') as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user['bio'] != null && (user['bio'] as String).isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        user['bio'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // 游戏标签功能暂不实现
                ],
              ),
            ),

            // 关注按钮
            if (showFollowButton)
              ElevatedButton(
                onPressed: onFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Colors.grey.shade300
                      : theme.colorScheme.primary,
                  foregroundColor: isFollowing
                      ? theme.colorScheme.onSurface
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  isFollowing ? '已关注' : '关注',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
