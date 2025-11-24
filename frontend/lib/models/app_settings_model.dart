enum NotificationType {
  system,     // 系统通知
  order,      // 订单通知
  message,    // 消息通知
  follow,     // 关注通知
  like,       // 点赞通知
  comment,    // 评论通知
  promotion,  // 推广通知
}

enum AppThemeMode {
  system,   // 跟随系统
  light,    // 浅色模式
  dark,     // 深色模式
}

class AppSettings {
  final String id;
  final String userId;
  
  // 通知设置
  final bool pushNotificationEnabled;    // 推送通知开关
  final Map<NotificationType, bool> notificationTypes; // 各类通知开关
  final bool soundEnabled;               // 声音开关
  final bool vibrationEnabled;           // 振动开关
  final bool inAppNotificationEnabled;   // 应用内通知开关
  
  // 隐私设置
  final bool profilePublic;              // 公开个人资料
  final bool showOnlineStatus;           // 显示在线状态
  final bool allowStrangerMessage;      // 允许陌生人消息
  final bool allowFollowRequest;         // 允许关注请求
  
  // 显示设置
  final AppThemeMode themeMode;             // 主题模式
  final double fontSize;                 // 字体大小
  final bool autoPlayVideo;              // 自动播放视频
  final bool highQualityImage;           // 高质量图片
  
  // 其他设置
  final bool autoUpdate;                 // 自动更新
  final String language;                  // 语言设置
  final bool cacheEnabled;               // 缓存开关
  final int cacheSize;                   // 缓存大小限制(MB)
  
  final DateTime createTime;
  final DateTime? updateTime;

  AppSettings({
    required this.id,
    required this.userId,
    this.pushNotificationEnabled = true,
    Map<NotificationType, bool>? notificationTypes,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.inAppNotificationEnabled = true,
    this.profilePublic = true,
    this.showOnlineStatus = true,
    this.allowStrangerMessage = false,
    this.allowFollowRequest = true,
    this.themeMode = AppThemeMode.system,
    this.fontSize = 14.0,
    this.autoPlayVideo = false,
    this.highQualityImage = true,
    this.autoUpdate = true,
    this.language = 'zh_CN',
    this.cacheEnabled = true,
    this.cacheSize = 100,
    required this.createTime,
    this.updateTime,
  }) : notificationTypes = notificationTypes ?? {
         NotificationType.system: true,
         NotificationType.order: true,
         NotificationType.message: true,
         NotificationType.follow: true,
         NotificationType.like: true,
         NotificationType.comment: true,
         NotificationType.promotion: false,
       };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      pushNotificationEnabled: json['pushNotificationEnabled'] ?? true,
      notificationTypes: (json['notificationTypes'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          NotificationType.values.firstWhere(
            (e) => e.name == key,
            orElse: () => NotificationType.system,
          ),
          value as bool,
        ),
      ) ?? {},
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      inAppNotificationEnabled: json['inAppNotificationEnabled'] ?? true,
      profilePublic: json['profilePublic'] ?? true,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      allowStrangerMessage: json['allowStrangerMessage'] ?? false,
      allowFollowRequest: json['allowFollowRequest'] ?? true,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      autoPlayVideo: json['autoPlayVideo'] ?? false,
      highQualityImage: json['highQualityImage'] ?? true,
      autoUpdate: json['autoUpdate'] ?? true,
      language: json['language'] ?? 'zh_CN',
      cacheEnabled: json['cacheEnabled'] ?? true,
      cacheSize: json['cacheSize'] ?? 100,
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pushNotificationEnabled': pushNotificationEnabled,
      'notificationTypes': notificationTypes.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'inAppNotificationEnabled': inAppNotificationEnabled,
      'profilePublic': profilePublic,
      'showOnlineStatus': showOnlineStatus,
      'allowStrangerMessage': allowStrangerMessage,
      'allowFollowRequest': allowFollowRequest,
      'themeMode': themeMode.name,
      'fontSize': fontSize,
      'autoPlayVideo': autoPlayVideo,
      'highQualityImage': highQualityImage,
      'autoUpdate': autoUpdate,
      'language': language,
      'cacheEnabled': cacheEnabled,
      'cacheSize': cacheSize,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }

  AppSettings copyWith({
    String? id,
    String? userId,
    bool? pushNotificationEnabled,
    Map<NotificationType, bool>? notificationTypes,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? inAppNotificationEnabled,
    bool? profilePublic,
    bool? showOnlineStatus,
    bool? allowStrangerMessage,
    bool? allowFollowRequest,
    AppThemeMode? themeMode,
    double? fontSize,
    bool? autoPlayVideo,
    bool? highQualityImage,
    bool? autoUpdate,
    String? language,
    bool? cacheEnabled,
    int? cacheSize,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return AppSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushNotificationEnabled: pushNotificationEnabled ?? this.pushNotificationEnabled,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      inAppNotificationEnabled: inAppNotificationEnabled ?? this.inAppNotificationEnabled,
      profilePublic: profilePublic ?? this.profilePublic,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowStrangerMessage: allowStrangerMessage ?? this.allowStrangerMessage,
      allowFollowRequest: allowFollowRequest ?? this.allowFollowRequest,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      autoPlayVideo: autoPlayVideo ?? this.autoPlayVideo,
      highQualityImage: highQualityImage ?? this.highQualityImage,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      language: language ?? this.language,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      cacheSize: cacheSize ?? this.cacheSize,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppSettings{id: $id, userId: $userId, themeMode: $themeMode}';
  }
}