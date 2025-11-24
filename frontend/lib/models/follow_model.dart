class FollowRelationship {
  final String id;
  final String followerId;
  final String followerName;
  final String followerAvatar;
  final String followingId;
  final String followingName;
  final String followingAvatar;
  final DateTime createTime;
  final FollowStatus status;

  FollowRelationship({
    required this.id,
    required this.followerId,
    required this.followerName,
    required this.followerAvatar,
    required this.followingId,
    required this.followingName,
    required this.followingAvatar,
    required this.createTime,
    required this.status,
  });

  factory FollowRelationship.fromJson(Map<String, dynamic> json) {
    return FollowRelationship(
      id: json['id']?.toString() ?? '',
      followerId: json['followerId']?.toString() ?? '',
      followerName: json['followerName'] ?? '',
      followerAvatar: json['followerAvatar'] ?? '',
      followingId: json['followingId']?.toString() ?? '',
      followingName: json['followingName'] ?? '',
      followingAvatar: json['followingAvatar'] ?? '',
      createTime: DateTime.parse(json['createTime'] ?? DateTime.now().toIso8601String()),
      status: FollowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FollowStatus.following,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'followerId': followerId,
      'followerName': followerName,
      'followerAvatar': followerAvatar,
      'followingId': followingId,
      'followingName': followingName,
      'followingAvatar': followingAvatar,
      'createTime': createTime.toIso8601String(),
      'status': status.name,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  String get statusText {
    switch (status) {
      case FollowStatus.following:
        return '已关注';
      case FollowStatus.pending:
        return '关注申请中';
      case FollowStatus.rejected:
        return '已拒绝';
      case FollowStatus.blocked:
        return '已拉黑';
    }
  }

  FollowRelationship copyWith({
    String? id,
    String? followerId,
    String? followerName,
    String? followerAvatar,
    String? followingId,
    String? followingName,
    String? followingAvatar,
    DateTime? createTime,
    FollowStatus? status,
  }) {
    return FollowRelationship(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followerName: followerName ?? this.followerName,
      followerAvatar: followerAvatar ?? this.followerAvatar,
      followingId: followingId ?? this.followingId,
      followingName: followingName ?? this.followingName,
      followingAvatar: followingAvatar ?? this.followingAvatar,
      createTime: createTime ?? this.createTime,
      status: status ?? this.status,
    );
  }

  static FollowRelationship empty() {
    return FollowRelationship(
      id: '',
      followerId: '',
      followerName: '',
      followerAvatar: '',
      followingId: '',
      followingName: '',
      followingAvatar: '',
      createTime: DateTime.now(),
      status: FollowStatus.following,
    );
  }
}

enum FollowStatus {
  following,  // 已关注
  pending,    // 关注申请中
  rejected,   // 已拒绝
  blocked     // 已拉黑
}

class UserStats {
  final String userId;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int likedCount;
  final DateTime lastActiveTime;

  UserStats({
    required this.userId,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.likedCount = 0,
    required this.lastActiveTime,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId']?.toString() ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      likedCount: json['likedCount'] ?? 0,
      lastActiveTime: DateTime.parse(json['lastActiveTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'likedCount': likedCount,
      'lastActiveTime': lastActiveTime.toIso8601String(),
    };
  }

  String get lastActiveAgo {
    final now = DateTime.now();
    final difference = now.difference(lastActiveTime);
    
    if (difference.inDays > 7) {
      return '7天前在线';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前在线';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前在线';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前在线';
    } else {
      return '刚刚在线';
    }
  }

  bool get isActiveRecently => 
      DateTime.now().difference(lastActiveTime).inMinutes < 5;

  UserStats copyWith({
    String? userId,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    int? likedCount,
    DateTime? lastActiveTime,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      likedCount: likedCount ?? this.likedCount,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
    );
  }

  static UserStats empty() {
    return UserStats(
      userId: '',
      lastActiveTime: DateTime.now(),
    );
  }
}