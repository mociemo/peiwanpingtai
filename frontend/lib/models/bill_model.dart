/// 账单模型
class Bill {
  /// 账单ID
  final String id;

  /// 用户ID
  final String userId;

  /// 账单类型：recharge-充值，consumption-消费，income-收入，withdrawal-提现
  final String type;

  /// 金额（正数为收入，负数为支出）
  final double amount;

  /// 余额
  final double balance;

  /// 描述
  final String description;

  /// 相关订单ID（如果有）
  final String? relatedOrderId;

  /// 创建时间
  final DateTime createTime;

  /// 交易类型名称
  String get typeName {
    switch (type) {
      case 'recharge':
        return '充值';
      case 'consumption':
        return '消费';
      case 'income':
        return '收入';
      case 'withdrawal':
        return '提现';
      default:
        return '未知';
    }
  }

  /// 是否为收入
  bool get isIncome => amount > 0;

  /// 是否为支出
  bool get isExpense => amount < 0;

  /// 格式化金额（带正负号）
  String get formattedAmount {
    final sign = amount >= 0 ? '+' : '';
    return '$sign¥${amount.abs().toStringAsFixed(2)}';
  }

  /// 格式化余额
  String get formattedBalance => '¥${balance.toStringAsFixed(2)}';

  const Bill({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balance,
    required this.description,
    required this.createTime,
    this.relatedOrderId,
  });

  /// 从JSON创建实例
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      description: json['description'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      relatedOrderId: json['relatedOrderId'] as String?,
    );
  }

  /// 创建一个空的Bill实例
  static Bill empty() {
    return Bill(
      id: '',
      userId: '',
      type: '',
      amount: 0.0,
      balance: 0.0,
      description: '',
      createTime: DateTime.now(),
      relatedOrderId: null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'balance': balance,
      'description': description,
      'createTime': createTime.toIso8601String(),
      'relatedOrderId': relatedOrderId,
    };
  }

  /// 创建副本并修改部分属性
  Bill copyWith({
    String? id,
    String? userId,
    String? type,
    double? amount,
    double? balance,
    String? description,
    DateTime? createTime,
    String? relatedOrderId,
  }) {
    return Bill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      createTime: createTime ?? this.createTime,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.amount == amount &&
        other.balance == balance &&
        other.description == description &&
        other.createTime == createTime &&
        other.relatedOrderId == relatedOrderId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      type,
      amount,
      balance,
      description,
      createTime,
      relatedOrderId,
    );
  }

  @override
  String toString() {
    return 'Bill{id: $id, userId: $userId, type: $type, amount: $amount, balance: $balance}';
  }
}
