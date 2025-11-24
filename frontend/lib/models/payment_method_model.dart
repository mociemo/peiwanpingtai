class PaymentMethod {
  final String id;
  final String type;
  final String name;
  final String description;
  final bool isDefault;
  final String? iconUrl;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    this.isDefault = false,
    this.iconUrl,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isDefault: json['isDefault'] ?? false,
      iconUrl: json['iconUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'isDefault': isDefault,
      'iconUrl': iconUrl,
    };
  }
}