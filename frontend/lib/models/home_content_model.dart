class HomeContent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String linkType; // "user", "post", "url", "activity"
  final String linkId; // 关联的ID，如果是url类型则为URL地址
  final int sortOrder; // 排序顺序，数字越小越靠前
  final bool isActive; // 是否启用
  final DateTime startTime; // 开始展示时间
  final DateTime endTime; // 结束展示时间
  final DateTime createTime;
  final DateTime updateTime;

  HomeContent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.linkType,
    required this.linkId,
    required this.sortOrder,
    required this.isActive,
    required this.startTime,
    required this.endTime,
    required this.createTime,
    required this.updateTime,
  });

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    return HomeContent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      linkType: json['linkType'] as String,
      linkId: json['linkId'] as String,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      createTime: DateTime.parse(json['createTime'] as String),
      updateTime: DateTime.parse(json['updateTime'] as String),
    );
  }
}

class RecommendedPlayer {
  final String id;
  final String nickname;
  final String avatar;
  final double rating;
  final List<String> gameTypes;
  final double price;
  final String intro;

  RecommendedPlayer({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.rating,
    required this.gameTypes,
    required this.price,
    required this.intro,
  });

  factory RecommendedPlayer.fromJson(Map<String, dynamic> json) {
    return RecommendedPlayer(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      rating: (json['rating'] as num).toDouble(),
      gameTypes: List<String>.from(json['gameTypes'] as List),
      price: (json['price'] as num).toDouble(),
      intro: json['intro'] as String,
    );
  }
}

class HotPost {
  final String id;
  final String userId;
  final String content;
  final List<String> images;
  final int likes;
  final int comments;
  final DateTime createTime;

  HotPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    required this.likes,
    required this.comments,
    required this.createTime,
  });

  factory HotPost.fromJson(Map<String, dynamic> json) {
    return HotPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] as List),
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      createTime: DateTime.parse(json['createTime'] as String),
    );
  }
}