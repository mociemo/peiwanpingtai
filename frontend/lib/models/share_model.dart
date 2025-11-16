class ShareRequest {
  final String userId; // 分享者ID
  final String shareType; // 分享类型: "user", "post", "order"
  final String shareId; // 分享内容的ID
  final String platform; // 分享平台: "wechat", "qq", "weibo" 等

  ShareRequest({
    required this.userId,
    required this.shareType,
    required this.shareId,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shareType': shareType,
      'shareId': shareId,
      'platform': platform,
    };
  }
}

class ShareResponse {
  final String shareId; // 分享ID
  final String shareUrl; // 分享链接
  final String title; // 分享标题
  final String description; // 分享描述
  final String imageUrl; // 分享图片
  final DateTime expireTime; // 链接过期时间

  ShareResponse({
    required this.shareId,
    required this.shareUrl,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.expireTime,
  });

  factory ShareResponse.fromJson(Map<String, dynamic> json) {
    return ShareResponse(
      shareId: json['shareId'] as String,
      shareUrl: json['shareUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      expireTime: DateTime.parse(json['expireTime'] as String),
    );
  }
}

class ShareStats {
  final int totalShares;
  final int totalViews;
  final Map<String, int> shareTypeStats;

  ShareStats({
    required this.totalShares,
    required this.totalViews,
    required this.shareTypeStats,
  });

  factory ShareStats.fromJson(Map<String, dynamic> json) {
    final shareTypeStats = <String, int>{};
    final statsMap = json['shareTypeStats'] as Map<String, dynamic>;

    statsMap.forEach((key, value) {
      shareTypeStats[key] = value as int;
    });

    return ShareStats(
      totalShares: json['totalShares'] as int,
      totalViews: json['totalViews'] as int,
      shareTypeStats: shareTypeStats,
    );
  }
}
