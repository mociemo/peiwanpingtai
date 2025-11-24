import 'user_model.dart';


class Player {
  final String id;
  final String userId;
  final String? realName;
  final String? idCard;
  final List<String> skillTags;
  final double servicePrice;
  final String? introduction;
  final CertificationStatus certificationStatus;
  final int totalOrders;
  final double rating;
  final Map<String, dynamic>? availableTime;
  final DateTime createTime;
  final User? user; // 关联的用户信息

  Player({
    required this.id,
    required this.userId,
    this.realName,
    this.idCard,
    required this.skillTags,
    required this.servicePrice,
    this.introduction,
    required this.certificationStatus,
    required this.totalOrders,
    required this.rating,
    this.availableTime,
    required this.createTime,
    this.user,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      realName: json['realName'],
      idCard: json['idCard'],
      skillTags: List<String>.from(json['skillTags'] ?? []),
      servicePrice: (json['servicePrice'] ?? 0.0).toDouble(),
      introduction: json['introduction'],
      certificationStatus: CertificationStatus.values.firstWhere(
        (e) => e.name == json['certificationStatus'],
        orElse: () => CertificationStatus.pending,
      ),
      totalOrders: json['totalOrders'] ?? 0,
      rating: (json['rating'] ?? 5.0).toDouble(),
      availableTime: json['availableTime'],
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'realName': realName,
      'idCard': idCard,
      'skillTags': skillTags,
      'servicePrice': servicePrice,
      'introduction': introduction,
      'certificationStatus': certificationStatus.name,
      'totalOrders': totalOrders,
      'rating': rating,
      'availableTime': availableTime,
      'createTime': createTime.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  Player copyWith({
    String? id,
    String? userId,
    String? realName,
    String? idCard,
    List<String>? skillTags,
    double? servicePrice,
    String? introduction,
    CertificationStatus? certificationStatus,
    int? totalOrders,
    double? rating,
    Map<String, dynamic>? availableTime,
    DateTime? createTime,
    User? user,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      realName: realName ?? this.realName,
      idCard: idCard ?? this.idCard,
      skillTags: skillTags ?? this.skillTags,
      servicePrice: servicePrice ?? this.servicePrice,
      introduction: introduction ?? this.introduction,
      certificationStatus: certificationStatus ?? this.certificationStatus,
      totalOrders: totalOrders ?? this.totalOrders,
      rating: rating ?? this.rating,
      availableTime: availableTime ?? this.availableTime,
      createTime: createTime ?? this.createTime,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Player{id: $id, userId: $userId, certificationStatus: $certificationStatus, rating: $rating}';
  }
}



enum CertificationStatus {
  pending,   // 待审核
  approved,  // 已通过
  rejected,  // 已拒绝
}