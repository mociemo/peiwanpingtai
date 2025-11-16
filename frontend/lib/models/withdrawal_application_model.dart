/// 提现申请模型
class WithdrawalApplication {
  /// 申请ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 提现金额
  final double amount;
  
  /// 账户类型：bank-银行卡，alipay-支付宝，wechat-微信
  final String accountType;
  
  /// 账户信息（银行卡号、支付宝账号等）
  final String accountInfo;
  
  /// 账户名称（银行卡开户名、支付宝姓名等）
  final String accountName;
  
  /// 申请状态：pending-待审核，approved-已通过，rejected-已拒绝，completed-已完成
  final String status;
  
  /// 创建时间
  final DateTime createTime;
  
  /// 处理时间
  final DateTime? processTime;
  
  /// 备注（拒绝原因等）
  final String? remark;
  
  /// 处理人ID（管理员）
  final String? processorId;
  
  /// 手续费
  final double? fee;
  
  /// 实际到账金额
  double get actualAmount => amount - (fee ?? 0);
  
  /// 是否待审核
  bool get isPending => status == 'pending';
  
  /// 是否已通过
  bool get isApproved => status == 'approved';
  
  /// 是否已拒绝
  bool get isRejected => status == 'rejected';
  
  /// 是否已完成
  bool get isCompleted => status == 'completed';

  const WithdrawalApplication({
    required this.id,
    required this.userId,
    required this.amount,
    required this.accountType,
    required this.accountInfo,
    required this.accountName,
    required this.status,
    required this.createTime,
    this.processTime,
    this.remark,
    this.processorId,
    this.fee,
  });

  /// 从JSON创建实例
  factory WithdrawalApplication.fromJson(Map<String, dynamic> json) {
    return WithdrawalApplication(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      accountType: json['accountType'] as String,
      accountInfo: json['accountInfo'] as String,
      accountName: json['accountName'] as String,
      status: json['status'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      processTime: json['processTime'] != null ? DateTime.parse(json['processTime'] as String) : null,
      remark: json['remark'] as String?,
      processorId: json['processorId'] as String?,
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : null,
    );
  }

  /// 创建一个空的WithdrawalApplication实例
  static WithdrawalApplication empty() {
    return WithdrawalApplication(
      id: '',
      userId: '',
      amount: 0.0,
      accountType: '',
      accountInfo: '',
      accountName: '',
      status: 'pending',
      createTime: DateTime.now(),
      processTime: null,
      remark: null,
      processorId: null,
      fee: null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'accountType': accountType,
      'accountInfo': accountInfo,
      'accountName': accountName,
      'status': status,
      'createTime': createTime.toIso8601String(),
      'processTime': processTime?.toIso8601String(),
      'remark': remark,
      'processorId': processorId,
      'fee': fee,
    };
  }

  /// 创建副本并修改部分属性
  WithdrawalApplication copyWith({
    String? id,
    String? userId,
    double? amount,
    String? accountType,
    String? accountInfo,
    String? accountName,
    String? status,
    DateTime? createTime,
    DateTime? processTime,
    String? remark,
    String? processorId,
    double? fee,
  }) {
    return WithdrawalApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      accountType: accountType ?? this.accountType,
      accountInfo: accountInfo ?? this.accountInfo,
      accountName: accountName ?? this.accountName,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      processTime: processTime ?? this.processTime,
      remark: remark ?? this.remark,
      processorId: processorId ?? this.processorId,
      fee: fee ?? this.fee,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WithdrawalApplication &&
        other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.accountType == accountType &&
        other.accountInfo == accountInfo &&
        other.accountName == accountName &&
        other.status == status &&
        other.createTime == createTime &&
        other.processTime == processTime &&
        other.remark == remark &&
        other.processorId == processorId &&
        other.fee == fee;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      amount,
      accountType,
      accountInfo,
      accountName,
      status,
      createTime,
      processTime,
      remark,
      processorId,
      fee,
    );
  }

  @override
  String toString() {
    return 'WithdrawalApplication{id: $id, userId: $userId, amount: $amount, accountType: $accountType, status: $status}';
  }
}