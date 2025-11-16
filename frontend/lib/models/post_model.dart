class Post {
  final String id;
  final String userId;
  final String userAvatar;
  final String userName;
  final String content;
  final List<String> images;
  final List<String> tags;
  final PostType type;
  final PostStatus status;
  final DateTime createTime;
  final DateTime? updateTime;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isCollected;
  final bool isPinned;
  final String? location;
  final String? gameName;
  final String? videoUrl;

  Post({
    required this.id,
    required this.userId,
    required this.userAvatar,
    required this.userName,
    required this.content,
    this.images = const [],
    this.tags = const [],
    required this.type,
    required this.status,
    required this.createTime,
    this.updateTime,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isCollected = false,
    this.isPinned = false,
    this.location,
    this.gameName,
    this.videoUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userAvatar: json['userAvatar'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.text,
      ),
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.published,
      ),
      createTime: DateTime.parse(json['createTime'] ?? DateTime.now().toIso8601String()),
      updateTime: json['updateTime'] != null ? DateTime.parse(json['updateTime']) : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isCollected: json['isCollected'] ?? false,
      isPinned: json['isPinned'] ?? false,
      location: json['location'],
      gameName: json['gameName'],
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userAvatar': userAvatar,
      'userName': userName,
      'content': content,
      'images': images,
      'tags': tags,
      'type': type.name,
      'status': status.name,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'isLiked': isLiked,
      'isCollected': isCollected,
      'isPinned': isPinned,
      'location': location,
      'gameName': gameName,
      'videoUrl': videoUrl,
    };
  }

  String get typeText {
    switch (type) {
      case PostType.text:
        return '文字';
      case PostType.image:
        return '图片';
      case PostType.video:
        return '视频';
      case PostType.game:
        return '游戏';
    }
  }

  String get statusText {
    switch (status) {
      case PostStatus.draft:
        return '草稿';
      case PostStatus.published:
        return '已发布';
      case PostStatus.private:
        return '私密';
      case PostStatus.deleted:
        return '已删除';
      case PostStatus.pending:
        return '审核中';
      case PostStatus.rejected:
        return '审核失败';
    }
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

  bool get hasContent => content.isNotEmpty;
  bool get hasImages => images.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  Post copyWith({
    String? id,
    String? userId,
    String? userAvatar,
    String? userName,
    String? content,
    List<String>? images,
    List<String>? tags,
    PostType? type,
    PostStatus? status,
    DateTime? createTime,
    DateTime? updateTime,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    bool? isCollected,
    bool? isPinned,
    String? location,
    String? gameName,
    String? videoUrl,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userAvatar: userAvatar ?? this.userAvatar,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isCollected: isCollected ?? this.isCollected,
      isPinned: isPinned ?? this.isPinned,
      location: location ?? this.location,
      gameName: gameName ?? this.gameName,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  static Post empty() {
    return Post(
      id: '',
      userId: '',
      userAvatar: '',
      userName: '',
      content: '',
      type: PostType.text,
      status: PostStatus.published,
      createTime: DateTime.now(),
    );
  }
}

enum PostType {
  text,      // 文字动态
  image,     // 图片动态
  video,     // 视频动态
  game       // 游戏动态
}

enum PostStatus {
  draft,      // 草稿
  published,  // 已发布
  private,    // 私密
  deleted,    // 已删除
  pending,    // 审核中
  rejected    // 审核失败
}