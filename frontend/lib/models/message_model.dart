enum MessageType {
  text,       // 文本消息
  image,      // 图片消息
  voice,      // 语音消息
  video,      // 视频消息
  location,   // 位置消息
  system,     // 系统消息
  custom,     // 自定义消息
}

enum MessageStatus {
  sending,    // 发送中
  sent,       // 已发送
  delivered,  // 已送达
  read,       // 已读
  failed,     // 发送失败
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final MessageType type;
  final String content;
  final MessageStatus status;
  final DateTime createTime;
  final DateTime? readTime;
  final Map<String, dynamic>? extra; // 额外数据，如图片尺寸、语音时长等

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    required this.status,
    required this.createTime,
    this.readTime,
    this.extra,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'] ?? '',
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sending,
      ),
      createTime: DateTime.parse(json['createTime'] ?? DateTime.now().toIso8601String()),
      readTime: json['readTime'] != null ? DateTime.parse(json['readTime']) : null,
      extra: json['extra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.name,
      'content': content,
      'status': status.name,
      'createTime': createTime.toIso8601String(),
      'readTime': readTime?.toIso8601String(),
      'extra': extra,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    MessageType? type,
    String? content,
    MessageStatus? status,
    DateTime? createTime,
    DateTime? readTime,
    Map<String, dynamic>? extra,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      content: content ?? this.content,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      readTime: readTime ?? this.readTime,
      extra: extra ?? this.extra,
    );
  }

  bool get isFromMe => false; // 需要根据当前用户ID判断
  bool get isTextMessage => type == MessageType.text;
  bool get isImageMessage => type == MessageType.image;
  bool get isVoiceMessage => type == MessageType.voice;
  bool get isVideoMessage => type == MessageType.video;
  bool get isSystemMessage => type == MessageType.system;
}