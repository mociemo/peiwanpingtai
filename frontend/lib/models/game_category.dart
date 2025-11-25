class GameCategory {
  final int id;
  final String name;
  final String? description;
  final String? iconUrl;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  GameCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    return GameCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['iconUrl'],
      sortOrder: json['sortOrder'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'sortOrder': sortOrder,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  GameCategory copyWith({
    int? id,
    String? name,
    String? description,
    String? iconUrl,
    int? sortOrder,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameCategory &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.iconUrl == iconUrl &&
        other.sortOrder == sortOrder &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, iconUrl, sortOrder, status);
  }

  @override
  String toString() {
    return 'GameCategory{id: $id, name: $name, status: $status}';
  }
}