enum TransactionType {
  recharge,    // 充值
  consumption, // 消费
  withdrawal,  // 提现
  refund,     // 退款
  reward,      // 奖励
}

enum TransactionStatus {
  pending,   // 待处理
  success,   // 成功
  failed,    // 失败
  cancelled, // 已取消
}

class Wallet {
  final String id;
  final String userId;
  final double balance;          // 可用余额
  final double frozenAmount;     // 冻结金额
  final double totalIncome;      // 总收入
  final double totalExpense;     // 总支出
  final DateTime createTime;
  final DateTime? updateTime;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.frozenAmount,
    required this.totalIncome,
    required this.totalExpense,
    required this.createTime,
    this.updateTime,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      frozenAmount: (json['frozenAmount'] ?? 0.0).toDouble(),
      totalIncome: (json['totalIncome'] ?? 0.0).toDouble(),
      totalExpense: (json['totalExpense'] ?? 0.0).toDouble(),
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'frozenAmount': frozenAmount,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }

  Wallet copyWith({
    String? id,
    String? userId,
    double? balance,
    double? frozenAmount,
    double? totalIncome,
    double? totalExpense,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      frozenAmount: frozenAmount ?? this.frozenAmount,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wallet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Wallet{id: $id, userId: $userId, balance: $balance}';
  }
}

class WalletTransaction {
  final String id;
  final String walletId;
  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final TransactionStatus status;
  final String? relatedOrderId;
  final String? relatedPaymentId;
  final DateTime createTime;
  final DateTime? updateTime;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    this.relatedOrderId,
    this.relatedPaymentId,
    required this.createTime,
    this.updateTime,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      walletId: json['walletId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.recharge,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      relatedOrderId: json['relatedOrderId'],
      relatedPaymentId: json['relatedPaymentId'],
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'status': status.name,
      'relatedOrderId': relatedOrderId,
      'relatedPaymentId': relatedPaymentId,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
    };
  }

  WalletTransaction copyWith({
    String? id,
    String? walletId,
    String? userId,
    TransactionType? type,
    double? amount,
    String? description,
    TransactionStatus? status,
    String? relatedOrderId,
    String? relatedPaymentId,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      relatedPaymentId: relatedPaymentId ?? this.relatedPaymentId,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WalletTransaction{id: $id, type: $type, amount: $amount, status: $status}';
  }
}