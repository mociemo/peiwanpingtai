class Activity {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String type;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final double? discountRate;
  final double? minAmount;
  final double? maxDiscount;
  final int? participantLimit;
  final int participantCount;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.type,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.discountRate,
    this.minAmount,
    this.maxDiscount,
    this.participantLimit,
    required this.participantCount,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: json['type'] ?? 'DISCOUNT',
      status: json['status'] ?? 'DRAFT',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      discountRate: json['discountRate']?.toDouble(),
      minAmount: json['minAmount']?.toDouble(),
      maxDiscount: json['maxDiscount']?.toDouble(),
      participantLimit: json['participantLimit'],
      participantCount: json['participantCount'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type,
      'status': status,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'discountRate': discountRate,
      'minAmount': minAmount,
      'maxDiscount': maxDiscount,
      'participantLimit': participantLimit,
      'participantCount': participantCount,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Activity copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? type,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    double? discountRate,
    double? minAmount,
    double? maxDiscount,
    int? participantLimit,
    int? participantCount,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      discountRate: discountRate ?? this.discountRate,
      minAmount: minAmount ?? this.minAmount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      participantLimit: participantLimit ?? this.participantLimit,
      participantCount: participantCount ?? this.participantCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isExpired => DateTime.now().isAfter(endTime);
  bool get isFull => participantLimit != null && participantCount >= participantLimit!;
  bool get isOngoing => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, type, status);
  }

  @override
  String toString() {
    return 'Activity{id: $id, title: $title, type: $type, status: $status}';
  }
}