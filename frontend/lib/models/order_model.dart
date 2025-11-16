class Order {
  final String id;
  final String orderNo;
  final String playerId;
  final String playerName;
  final String playerAvatar;
  final double amount;
  final int duration; // 时长（分钟）
  final OrderStatus status;
  final ServiceType serviceType;
  final String requirements;
  final String contactInfo;
  final DateTime createTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? cancelReason;
  final double? rating;
  final String? comment;
  final DateTime? commentTime;

  Order({
    required this.id,
    required this.orderNo,
    required this.playerId,
    required this.playerName,
    required this.playerAvatar,
    required this.amount,
    required this.duration,
    required this.status,
    required this.serviceType,
    required this.requirements,
    required this.contactInfo,
    required this.createTime,
    this.startTime,
    this.endTime,
    this.cancelReason,
    this.rating,
    this.comment,
    this.commentTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      orderNo: json['orderNo'] ?? '',
      playerId: json['playerId']?.toString() ?? '',
      playerName: json['playerName'] ?? '',
      playerAvatar: json['playerAvatar'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] ?? 0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.gameGuide,
      ),
      requirements: json['requirements'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      cancelReason: json['cancelReason'],
      rating: (json['rating'] as num?)?.toDouble(),
      comment: json['comment'],
      commentTime: json['commentTime'] != null
          ? DateTime.parse(json['commentTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'playerId': playerId,
      'playerName': playerName,
      'playerAvatar': playerAvatar,
      'amount': amount,
      'duration': duration,
      'status': status.name,
      'serviceType': serviceType.name,
      'requirements': requirements,
      'contactInfo': contactInfo,
      'createTime': createTime.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'cancelReason': cancelReason,
      'rating': rating,
      'comment': comment,
      'commentTime': commentTime?.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return '待接单';
      case OrderStatus.accepted:
        return '已接单';
      case OrderStatus.inProgress:
        return '进行中';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.cancelled:
        return '已取消';
      case OrderStatus.refunded:
        return '已退款';
    }
  }

  String get serviceTypeText {
    switch (serviceType) {
      case ServiceType.voice:
        return '语音陪玩';
      case ServiceType.video:
        return '视频陪玩';
      case ServiceType.gameGuide:
        return '游戏指导';
      case ServiceType.entertainment:
        return '娱乐陪玩';
    }
  }

  double get totalAmount => amount * (duration / 60);
}

enum OrderStatus {
  pending, // 待接单
  accepted, // 已接单
  inProgress, // 进行中
  completed, // 已完成
  cancelled, // 已取消
  refunded, // 已退款
}

enum ServiceType {
  voice, // 语音陪玩
  video, // 视频陪玩
  gameGuide, // 游戏指导
  entertainment, // 娱乐陪玩
}
