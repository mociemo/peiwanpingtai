class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userAvatar;
  final String userName;
  final String content;
  final String? parentId;
  final String? replyToUserId;
  final String? replyToUserName;
  final DateTime createTime;
  final int likeCount;
  final bool isLiked;
  final List<Comment> replies;
  final CommentStatus status;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userAvatar,
    required this.userName,
    required this.content,
    this.parentId,
    this.replyToUserId,
    this.replyToUserName,
    required this.createTime,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
    required this.status,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userAvatar: json['userAvatar'] ?? '',
      userName: json['userName'] ?? '',
      content: json['content'] ?? '',
      parentId: json['parentId'],
      replyToUserId: json['replyToUserId'],
      replyToUserName: json['replyToUserName'],
      createTime: DateTime.parse(json['createTime'] ?? DateTime.now().toIso8601String()),
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      replies: (json['replies'] as List?)?.map((e) => Comment.fromJson(e)).toList() ?? [],
      status: CommentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CommentStatus.published,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userAvatar': userAvatar,
      'userName': userName,
      'content': content,
      'parentId': parentId,
      'replyToUserId': replyToUserId,
      'replyToUserName': replyToUserName,
      'createTime': createTime.toIso8601String(),
      'likeCount': likeCount,
      'isLiked': isLiked,
      'replies': replies.map((e) => e.toJson()).toList(),
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

  bool get isReply => parentId != null;
  bool get hasReplies => replies.isNotEmpty;

  String get statusText {
    switch (status) {
      case CommentStatus.published:
        return '已发布';
      case CommentStatus.deleted:
        return '已删除';
      case CommentStatus.pending:
        return '审核中';
      case CommentStatus.rejected:
        return '审核失败';
    }
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userAvatar,
    String? userName,
    String? content,
    String? parentId,
    String? replyToUserId,
    String? replyToUserName,
    DateTime? createTime,
    int? likeCount,
    bool? isLiked,
    List<Comment>? replies,
    CommentStatus? status,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userAvatar: userAvatar ?? this.userAvatar,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      replyToUserId: replyToUserId ?? this.replyToUserId,
      replyToUserName: replyToUserName ?? this.replyToUserName,
      createTime: createTime ?? this.createTime,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
      status: status ?? this.status,
    );
  }

  static Comment empty() {
    return Comment(
      id: '',
      postId: '',
      userId: '',
      userAvatar: '',
      userName: '',
      content: '',
      createTime: DateTime.now(),
      status: CommentStatus.published,
    );
  }
}

enum CommentStatus {
  published,  // 已发布
  deleted,    // 已删除
  pending,    // 审核中
  rejected    // 审核失败
}