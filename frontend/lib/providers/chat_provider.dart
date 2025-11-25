import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../services/call_service.dart';
import '../utils/navigator_service.dart';

class ChatProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  final Map<String, List<Message>> _conversationMessages = {};
  String? _currentConversationId;
  bool _isLoading = false;
  String? _error;
  int _totalUnreadCount = 0;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  String? get currentConversationId => _currentConversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUnreadCount => _totalUnreadCount;

  // 初始化
  Future<void> initialize() async {
    await _connectWebSocket();
    await loadConversations();
    await _updateUnreadCount();
  }

  // 连接WebSocket
  Future<void> _connectWebSocket() async {
    try {
      await WebSocketService.instance.connect();
      
      // 监听消息
      WebSocketService.instance.messageStream.listen((message) {
        _handleNewMessage(message);
      });
      
      // 监听事件
      WebSocketService.instance.eventStream.listen((event) {
        _handleWebSocketEvent(event);
      });
    } catch (e) {
      setError('连接聊天服务失败: $e');
    }
  }

  // 加载会话列表
  Future<void> loadConversations({bool refresh = false}) async {
    if (refresh) {
      _conversations.clear();
    }
    
    setLoading(true);
    clearError();
    
    try {
      final response = await ChatService.getConversations();
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data']['content'] ?? [];
        _conversations = data.map((item) => Conversation.fromJson(item)).toList();
        notifyListeners();
      } else {
        setError(response['message'] ?? '获取会话列表失败');
      }
    } catch (e) {
      setError('获取会话列表失败: $e');
    } finally {
      setLoading(false);
    }
  }

  // 加载消息列表
  Future<void> loadMessages(String conversationId, {bool refresh = false}) async {
    if (refresh) {
      _messages.clear();
      _conversationMessages[conversationId]?.clear();
    }
    
    _currentConversationId = conversationId;
    setLoading(true);
    clearError();
    
    try {
      // 如果已有缓存消息，先显示缓存
      if (_conversationMessages.containsKey(conversationId) && 
          _conversationMessages[conversationId]!.isNotEmpty) {
        _messages = _conversationMessages[conversationId]!;
        notifyListeners();
      }
      
      final response = await ChatService.getMessages(conversationId);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data']['content'] ?? [];
        final newMessages = data.map((item) => Message.fromJson(item)).toList();
        
        // 合并消息（去重）
        final existingIds = _messages.map((m) => m.id).toSet();
        final uniqueNewMessages = newMessages.where((m) => !existingIds.contains(m.id)).toList();
        
        _messages = [...uniqueNewMessages, ..._messages];
        _conversationMessages[conversationId] = _messages;
        
        // 标记消息为已读
        await markMessagesAsRead(conversationId);
        
        notifyListeners();
      } else {
        setError(response['message'] ?? '获取消息列表失败');
      }
    } catch (e) {
      setError('获取消息列表失败: $e');
    } finally {
      setLoading(false);
    }
  }

  // 发送文本消息
  Future<void> sendTextMessage(String conversationId, String content) async {
    if (content.trim().isEmpty) return;
    
    // 创建本地消息
    final localMessage = Message(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: await _getCurrentUserId(),
      receiverId: '', // 需要从会话中获取
      type: MessageType.text,
      content: content,
      status: MessageStatus.sending,
      createTime: DateTime.now(),
    );
    
    // 添加到消息列表
    _messages = [..._messages, localMessage];
    _conversationMessages[conversationId] = _messages;
    notifyListeners();
    
    try {
      // 发送消息
      final response = await ChatService.sendTextMessage(conversationId, content);
      
      if (response['success'] == true && response['data'] != null) {
        // 更新消息状态
        final serverMessage = Message.fromJson(response['data']);
        _updateMessage(localMessage.id, serverMessage);
      } else {
        // 发送失败，更新状态
        _updateMessageStatus(localMessage.id, MessageStatus.failed);
        setError(response['message'] ?? '发送消息失败');
      }
    } catch (e) {
      // 发送失败，更新状态
      _updateMessageStatus(localMessage.id, MessageStatus.failed);
      setError('发送消息失败: $e');
    }
  }

  // 创建会话
  Future<String?> createConversation(String participantId) async {
    setLoading(true);
    clearError();
    
    try {
      final response = await ChatService.createConversation(participantId);
      
      if (response['success'] == true && response['data'] != null) {
        final conversation = Conversation.fromJson(response['data']);
        _conversations.insert(0, conversation);
        notifyListeners();
        return conversation.id;
      } else {
        setError(response['message'] ?? '创建会话失败');
        return null;
      }
    } catch (e) {
      setError('创建会话失败: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  // 标记消息为已读
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await ChatService.markMessagesAsRead(conversationId);
      
      // 更新本地未读数
      final conversation = _conversations.where((c) => c.id == conversationId).firstOrNull;
      if (conversation != null) {
        final index = _conversations.indexOf(conversation);
        _conversations[index] = conversation.copyWith(unreadCount: 0);
        notifyListeners();
      }
      
      await _updateUnreadCount();
    } catch (e) {
      // 不显示错误，因为标记已读失败不影响用户体验
      if (kDebugMode) print('标记消息已读失败: $e');
    }
  }

  // 处理新消息
  void _handleNewMessage(Message message) {
    // 如果是当前会话的消息，添加到消息列表
    if (message.conversationId == _currentConversationId) {
      _messages = [..._messages, message];
      _conversationMessages[message.conversationId] = _messages;
      
      // 如果不是自己发送的消息，标记为已读
      if (message.senderId != _getCurrentUserIdSync()) {
        markMessagesAsRead(message.conversationId);
      }
    }
    
    // 更新会话列表中的最后一条消息
    _updateConversationLastMessage(message);
    
    notifyListeners();
  }

  // 处理WebSocket事件
  void _handleWebSocketEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'read':
        // 消息已读事件
        final messageId = event['messageId'];
        _updateMessageStatus(messageId, MessageStatus.read);
        break;
      case 'online_status':
        // 用户在线状态变更
        final userId = event['userId'];
        final isOnline = event['isOnline'];
        _updateUserOnlineStatus(userId, isOnline);
        break;
      case 'call':
        // 收到通话请求
        _handleIncomingCall(event);
        break;
      case 'call_response':
        // 收到通话响应
        _handleCallResponse(event);
        break;
    }
  }

  // 更新消息
  void _updateMessage(String tempId, Message newMessage) {
    final index = _messages.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      _messages[index] = newMessage;
      _conversationMessages[newMessage.conversationId] = _messages;
      notifyListeners();
    }
  }

  // 更新消息状态
  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  // 更新会话最后一条消息
  void _updateConversationLastMessage(Message message) {
    final index = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (index != -1) {
      final conversation = _conversations[index];
      _conversations[index] = conversation.copyWith(
        lastMessage: message.content,
        lastMessageTime: message.createTime,
        unreadCount: message.senderId != _getCurrentUserIdSync() 
            ? conversation.unreadCount + 1 
            : conversation.unreadCount,
      );
      
      // 将该会话移到顶部
      final updatedConversation = _conversations.removeAt(index);
      _conversations.insert(0, updatedConversation);
      
      notifyListeners();
    }
  }

  // 更新用户在线状态
  void _updateUserOnlineStatus(String userId, bool isOnline) {
    final index = _conversations.indexWhere((c) => c.participantId == userId);
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(
        isOnline: isOnline,
        lastOnlineTime: isOnline ? null : DateTime.now(),
      );
      notifyListeners();
    }
  }

  // 更新总未读数
  Future<void> _updateUnreadCount() async {
    try {
      final response = await ChatService.getUnreadCount();
      if (response['success'] == true) {
        _totalUnreadCount = response['data'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('获取未读消息数失败: $e');
    }
  }

  // 获取当前用户ID
  Future<String> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  // 同步获取当前用户ID
  String _getCurrentUserIdSync() {
    // 从SharedPreferences同步获取用户ID
    // 注意：这里需要同步访问，但在实际应用中应该通过状态管理获取
    return '';
  }

  // 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 设置错误信息
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  // 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 清除当前会话
  void clearCurrentConversation() {
    _currentConversationId = null;
    _messages.clear();
    notifyListeners();
  }

  // 处理来电
  void _handleIncomingCall(Map<String, dynamic> event) {
    final conversationId = event['conversationId'] ?? '';
    final participantId = event['participantId'] ?? '';
    final participantName = event['participantName'] ?? '';
    final participantAvatar = event['participantAvatar'] ?? '';
    final callType = event['callType'] ?? 'voice';
    final callId = event['callId'] ?? '';
    
    // 导航到来电页面
    NavigatorService.pushNamed('/chat/$conversationId/incoming', arguments: {
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'isVideoCall': callType == 'video',
      'callId': callId,
    });
  }

  // 处理通话响应
  void _handleCallResponse(Map<String, dynamic> event) {
    // 使用CallService处理通话响应
    CallService().handleCallResponse(event);
  }

  // 发送图片消息
  Future<void> sendImageMessage(String conversationId, String imagePath) async {
    setLoading(true);
    clearError();
    
    try {
      final response = await ChatService.sendImageMessage(conversationId, imagePath);
      
      if (response['success'] == true && response['data'] != null) {
        final message = Message.fromJson(response['data']);
        _messages = [..._messages, message];
        _conversationMessages[conversationId] = _messages;
        notifyListeners();
      } else {
        setError(response['message'] ?? '发送图片失败');
      }
    } catch (e) {
      setError('发送图片失败: $e');
    } finally {
      setLoading(false);
    }
  }

  // 发送语音消息
  Future<void> sendVoiceMessage(String conversationId, {String? voicePath, int? duration}) async {
    setLoading(true);
    clearError();
    
    try {
 // 验证语音文件参数
      if (voicePath == null || voicePath.isEmpty) {
        setError('语音文件路径无效');
        return;
      }
      
      if (duration == null || duration <= 0) {
        setError('语音时长无效');
        return;
      }
      
      final response = await ChatService.sendVoiceMessage(conversationId, voicePath, duration);
      
      if (response['success'] == true && response['data'] != null) {
        final message = Message.fromJson(response['data']);
        _messages = [..._messages, message];
        _conversationMessages[conversationId] = _messages;
        notifyListeners();
      } else {
        setError(response['message'] ?? '发送语音失败');
      }
    } catch (e) {
      setError('发送语音失败: $e');
    } finally {
      setLoading(false);
    }
  }

  // 发送位置消息
  Future<void> sendLocationMessage(String conversationId, {double? latitude, double? longitude, String? address}) async {
    setLoading(true);
    clearError();
    
    try {
      // 如果没有提供位置信息，使用默认位置（实际应用中应该获取当前位置）
      final lat = latitude ?? 39.9042; // 北京天安门纬度
      final lng = longitude ?? 116.4074; // 北京天安门经度
      final addr = address ?? '北京市东城区天安门广场';
      
      final response = await ChatService.sendLocationMessage(conversationId, lat, lng, addr);
      
      if (response['success'] == true && response['data'] != null) {
        final message = Message.fromJson(response['data']);
        _messages = [..._messages, message];
        _conversationMessages[conversationId] = _messages;
        notifyListeners();
      } else {
        setError(response['message'] ?? '发送位置失败');
      }
    } catch (e) {
      setError('发送位置失败: $e');
    } finally {
      setLoading(false);
    }
  }

  // 搜索用户
  Future<List<Conversation>> searchUsers(String query) async {
    try {
      final response = await ChatService.searchUsers(query);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((item) => Conversation.fromJson(item)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('搜索用户失败: $e');
    }
    
    return [];
  }

  @override
  void dispose() {
    WebSocketService.instance.dispose();
    super.dispose();
  }
}