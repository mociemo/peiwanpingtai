enum UserRole {
  user, // 普通用户
  vip, // VIP用户
  player, // 陪玩达人
  admin, // 管理员
}

enum UserStatus {
  active, // 活跃
  inactive, // 非活跃
  banned, // 封禁
}

class User {
  final String id;
  final String username;
  final String nickname;
  final String avatar;
  final String? bio;
  final String? location;
  final UserRole role;
  final UserStatus status;
  final DateTime createTime;
  final DateTime? lastLoginTime;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final int likeCount;
  final bool isFollowed;
  final bool isFollowing;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    this.bio,
    this.location,
    required this.role,
    required this.status,
    required this.createTime,
    this.lastLoginTime,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.likeCount = 0,
    this.isFollowed = false,
    this.isFollowing = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      bio: json['bio'],
      location: json['location'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      lastLoginTime: json['lastLoginTime'] != null
          ? DateTime.parse(json['lastLoginTime'])
          : null,
      postCount: json['postCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      isFollowed: json['isFollowed'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'bio': bio,
      'location': location,
      'role': role.name,
      'status': status.name,
      'createTime': createTime.toIso8601String(),
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'postCount': postCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'likeCount': likeCount,
      'isFollowed': isFollowed,
      'isFollowing': isFollowing,
    };
  }

  String get roleText {
    switch (role) {
      case UserRole.user:
        return '用户';
      case UserRole.vip:
        return 'VIP用户';
      case UserRole.player:
        return '陪玩达人';
      case UserRole.admin:
        return '管理员';
    }
  }

  String get statusText {
    switch (status) {
      case UserStatus.active:
        return '活跃';
      case UserStatus.inactive:
        return '非活跃';
      case UserStatus.banned:
        return '封禁';
    }
  }

  String get createTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(createTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前加入';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}月前加入';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前加入';
    } else {
      return '今天加入';
    }
  }

  String get lastActiveAgo {
    if (lastLoginTime == null) return '从未登录';

    final now = DateTime.now();
    final difference = now.difference(lastLoginTime!);

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
      lastLoginTime != null &&
      DateTime.now().difference(lastLoginTime!).inMinutes < 5;

  User copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatar,
    String? bio,
    String? location,
    UserRole? role,
    UserStatus? status,
    DateTime? createTime,
    DateTime? lastLoginTime,
    int? postCount,
    int? followerCount,
    int? followingCount,
    int? likeCount,
    bool? isFollowed,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      role: role ?? this.role,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      likeCount: likeCount ?? this.likeCount,
      isFollowed: isFollowed ?? this.isFollowed,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  static User empty() {
    return User(
      id: '',
      username: '',
      nickname: '',
      avatar: '',
      role: UserRole.user,
      status: UserStatus.active,
      createTime: DateTime.now(),
    );
  }
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
      lastActiveTime: DateTime.parse(
        json['lastActiveTime'] ?? DateTime.now().toIso8601String(),
      ),
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
    return UserStats(userId: '', lastActiveTime: DateTime.now());
  }
}
