class RatingRequest {
  final String orderId;
  final int rating;
  final String comment;
  final List<String> tags;

  RatingRequest({
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
    };
  }
}

class RatingResponse {
  final String id;
  final String orderId;
  final String raterId;
  final String raterName;
  final String raterAvatar;
  final String playerId;
  final String playerName;
  final int rating;
  final String comment;
  final List<String> tags;
  final DateTime createTime;

  RatingResponse({
    required this.id,
    required this.orderId,
    required this.raterId,
    required this.raterName,
    required this.raterAvatar,
    required this.playerId,
    required this.playerName,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.createTime,
  });

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      raterId: json['raterId'] as String,
      raterName: json['raterName'] as String,
      raterAvatar: json['raterAvatar'] as String,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      tags: List<String>.from(json['tags'] as List),
      createTime: DateTime.parse(json['createTime'] as String),
    );
  }
}

class RatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingCounts;

  RatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingCounts,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    final ratingCounts = <int, int>{};
    final countsMap = json['ratingCounts'] as Map<String, dynamic>;
    
    countsMap.forEach((key, value) {
      ratingCounts[int.parse(key)] = value as int;
    });

    return RatingStats(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      ratingCounts: ratingCounts,
    );
  }
}