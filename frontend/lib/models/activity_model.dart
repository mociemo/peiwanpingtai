enum ActivityType {
  promotion,    // 促销活动
  event,        // 活动事件
  announcement, // 公告
  holiday,      // 节日活动
  tournament,   // 竞赛活动
}

enum ActivityStatus {
  draft,        // 草稿
  active,       // 进行中
  paused,       // 暂停
  ended,        // 已结束
  cancelled,    // 已取消
}

class Activity {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? bannerUrl;
  final ActivityType type;
  final ActivityStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic>? rules;        // 活动规则
  final Map<String, dynamic>? rewards;       // 奖励设置
  final int participantCount;                // 参与人数
  final int viewCount;                       // 浏览次数
  final int shareCount;                      // 分享次数
  final bool isTop;                          // 是否置顶
  final int sortOrder;                       // 排序
  final String? linkUrl;                     // 外部链接
  final String? linkType;                    // 链接类型
  final String? linkId;                      // 链接ID
  final DateTime createTime;
  final DateTime? updateTime;
  final DateTime? publishTime;               // 发布时间

  Activity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.bannerUrl,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.rules,
    this.rewards,
    this.participantCount = 0,
    this.viewCount = 0,
    this.shareCount = 0,
    this.isTop = false,
    this.sortOrder = 0,
    this.linkUrl,
    this.linkType,
    this.linkId,
    required this.createTime,
    this.updateTime,
    this.publishTime,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      bannerUrl: json['bannerUrl'],
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.promotion,
      ),
      status: ActivityStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ActivityStatus.draft,
      ),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      rules: json['rules'],
      rewards: json['rewards'],
      participantCount: json['participantCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      isTop: json['isTop'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      linkUrl: json['linkUrl'],
      linkType: json['linkType'],
      linkId: json['linkId'],
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
      publishTime: json['publishTime'] != null
          ? DateTime.parse(json['publishTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'bannerUrl': bannerUrl,
      'type': type.name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'rules': rules,
      'rewards': rewards,
      'participantCount': participantCount,
      'viewCount': viewCount,
      'shareCount': shareCount,
      'isTop': isTop,
      'sortOrder': sortOrder,
      'linkUrl': linkUrl,
      'linkType': linkType,
      'linkId': linkId,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
      'publishTime': publishTime?.toIso8601String(),
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? bannerUrl,
    ActivityType? type,
    ActivityStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? rules,
    Map<String, dynamic>? rewards,
    int? participantCount,
    int? viewCount,
    int? shareCount,
    bool? isTop,
    int? sortOrder,
    String? linkUrl,
    String? linkType,
    String? linkId,
    DateTime? createTime,
    DateTime? updateTime,
    DateTime? publishTime,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rules: rules ?? this.rules,
      rewards: rewards ?? this.rewards,
      participantCount: participantCount ?? this.participantCount,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      isTop: isTop ?? this.isTop,
      sortOrder: sortOrder ?? this.sortOrder,
      linkUrl: linkUrl ?? this.linkUrl,
      linkType: linkType ?? this.linkType,
      linkId: linkId ?? this.linkId,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      publishTime: publishTime ?? this.publishTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Activity{id: $id, title: $title, type: $type, status: $status}';
  }
}

class ActivityParticipant {
  final String id;
  final String activityId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final Map<String, dynamic>? participationData; // 参与数据
  final DateTime joinTime;
  final DateTime? updateTime;

  ActivityParticipant({
    required this.id,
    required this.activityId,
    required this.userId,
    this.userName,
    this.userAvatar,
    this.participationData,
    required this.joinTime,
    this.updateTime,
  });

  factory ActivityParticipant.fromJson(Map<String, dynamic> json) {
    return ActivityParticipant(
      id: json['id']?.toString() ?? '',
      activityId: json['activityId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      participationData: json['participationData'],
      joinTime: DateTime.parse(json['joinTime']),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'participationData': participationData,
      'joinTime': joinTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }
}