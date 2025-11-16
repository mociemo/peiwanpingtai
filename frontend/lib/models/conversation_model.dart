class Conversation {
  final String id;
  final String userId; // 当前用户ID
  final String participantId; // 对话参与者ID
  final String participantName;
  final String participantAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastOnlineTime;
  final DateTime createTime;

  Conversation({
    required this.id,
    required this.userId,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastOnlineTime,
    required this.createTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? '',
      participantName: json['participantName'] ?? '',
      participantAvatar: json['participantAvatar'] ?? '',
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      lastOnlineTime: json['lastOnlineTime'] != null
          ? DateTime.parse(json['lastOnlineTime'])
          : null,
      createTime: DateTime.parse(
        json['createTime'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'lastOnlineTime': lastOnlineTime?.toIso8601String(),
      'createTime': createTime.toIso8601String(),
    };
  }

  Conversation copyWith({
    String? id,
    String? userId,
    String? participantId,
    String? participantName,
    String? participantAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastOnlineTime,
    DateTime? createTime,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantAvatar: participantAvatar ?? this.participantAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastOnlineTime: lastOnlineTime ?? this.lastOnlineTime,
      createTime: createTime ?? this.createTime,
    );
  }

  String get lastMessageDisplay {
    if (lastMessage == null || lastMessage!.isEmpty) {
      return '暂无消息';
    }
    return lastMessage!.length > 30
        ? '${lastMessage!.substring(0, 30)}...'
        : lastMessage!;
  }

  String get lastTimeDisplay {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(lastMessageTime!);

    if (diff.inDays > 0) {
      return '${lastMessageTime!.month}/${lastMessageTime!.day}';
    } else if (diff.inHours > 0) {
      return '${lastMessageTime!.hour}:${lastMessageTime!.minute.toString().padLeft(2, '0')}';
    } else {
      return '${lastMessageTime!.hour}:${lastMessageTime!.minute.toString().padLeft(2, '0')}';
    }
  }
}
