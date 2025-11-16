/// 充值订单模型
class RechargeOrder {
  /// 订单ID
  final String id;

  /// 用户ID
  final String userId;

  /// 充值金额
  final double amount;

  /// 支付方式：wechat-微信，alipay-支付宝，bank-银行卡
  final String paymentMethod;

  /// 订单状态：pending-待支付，paid-已支付，failed-支付失败，cancelled-已取消
  final String status;

  /// 创建时间
  final DateTime createTime;

  /// 支付时间
  final DateTime? payTime;

  /// 第三方交易ID
  final String? transactionId;

  /// 优惠金额
  final double? discountAmount;

  /// 优惠券ID
  final String? discountId;

  /// 实际支付金额
  double get actualAmount => amount - (discountAmount ?? 0);

  /// 是否已支付
  bool get isPaid => status == 'paid';

  /// 是否待支付
  bool get isPending => status == 'pending';

  /// 是否支付失败
  bool get isFailed => status == 'failed';

  /// 是否已取消
  bool get isCancelled => status == 'cancelled';

  const RechargeOrder({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createTime,
    this.payTime,
    this.transactionId,
    this.discountAmount,
    this.discountId,
  });

  /// 从JSON创建实例
  factory RechargeOrder.fromJson(Map<String, dynamic> json) {
    return RechargeOrder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      payTime: json['payTime'] != null
          ? DateTime.parse(json['payTime'] as String)
          : null,
      transactionId: json['transactionId'] as String?,
      discountAmount: json['discountAmount'] != null
          ? (json['discountAmount'] as num).toDouble()
          : null,
      discountId: json['discountId'] as String?,
    );
  }

  /// 创建一个空的RechargeOrder实例
  static RechargeOrder empty() {
    return RechargeOrder(
      id: '',
      userId: '',
      amount: 0.0,
      paymentMethod: '',
      status: 'pending',
      createTime: DateTime.now(),
      payTime: null,
      transactionId: null,
      discountAmount: null,
      discountId: null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'payTime': payTime?.toIso8601String(),
      'transactionId': transactionId,
      'discountAmount': discountAmount,
      'discountId': discountId,
    };
  }

  /// 创建副本并修改部分属性
  RechargeOrder copyWith({
    String? id,
    String? userId,
    double? amount,
    String? paymentMethod,
    String? status,
    DateTime? createTime,
    DateTime? payTime,
    String? transactionId,
    double? discountAmount,
    String? discountId,
  }) {
    return RechargeOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      payTime: payTime ?? this.payTime,
      transactionId: transactionId ?? this.transactionId,
      discountAmount: discountAmount ?? this.discountAmount,
      discountId: discountId ?? this.discountId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RechargeOrder &&
        other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.paymentMethod == paymentMethod &&
        other.status == status &&
        other.createTime == createTime &&
        other.payTime == payTime &&
        other.transactionId == transactionId &&
        other.discountAmount == discountAmount &&
        other.discountId == discountId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      amount,
      paymentMethod,
      status,
      createTime,
      payTime,
      transactionId,
      discountAmount,
      discountId,
    );
  }

  @override
  String toString() {
    return 'RechargeOrder{id: $id, userId: $userId, amount: $amount, paymentMethod: $paymentMethod, status: $status}';
  }
}
