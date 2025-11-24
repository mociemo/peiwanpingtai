enum GameCategoryStatus {
  active,   // 启用
  inactive, // 禁用
}

class GameCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int sortOrder;
  final GameCategoryStatus status;
  final DateTime createTime;

  GameCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.sortOrder,
    required this.status,
    required this.createTime,
  });

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    return GameCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      status: GameCategoryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GameCategoryStatus.active,
      ),
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'sortOrder': sortOrder,
      'status': status.name,
      'createTime': createTime.toIso8601String(),
    };
  }

  GameCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    int? sortOrder,
    GameCategoryStatus? status,
    DateTime? createTime,
  }) {
    return GameCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GameCategory{id: $id, name: $name, status: $status}';
  }
}