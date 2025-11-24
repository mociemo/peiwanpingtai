import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../config/api_config.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<Map<String, dynamic>> _eventController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Message> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (token == null || userId == null) {
        throw Exception('未登录或用户信息不完整');
      }

      // 连接WebSocket服务器
      final uri = Uri.parse('${ApiConfig.wsBaseUrl}?token=$token&userId=$userId');
      _channel = WebSocketChannel.connect(uri);

      // 监听消息
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      // 发送连接成功消息
      _sendEvent({
        'type': 'connect',
        'userId': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // 启动心跳
      _startHeartbeat();

      _isConnected = true;
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'message') {
        final messageData = data['data'];
        final msg = Message.fromJson(messageData);
        _messageController.add(msg);
      } else if (data['type'] == 'event') {
        _eventController.add(data);
      } else if (data['type'] == 'pong') {
        // 心跳响应，不需要处理
      }
    } catch (e) {
      if (kDebugMode) print('解析WebSocket消息失败: $e');
    }
  }

  void _handleError(dynamic error) {
    if (kDebugMode) print('WebSocket连接错误: $error');
    _isConnected = false;
    _stopHeartbeat();
    
    // 可以在这里添加重连逻辑
    _scheduleReconnect();
  }

  void _handleDone() {
    if (kDebugMode) print('WebSocket连接关闭');
    _isConnected = false;
    _stopHeartbeat();
    
    // 可以在这里添加重连逻辑
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendEvent({
        'type': 'ping',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void _sendEvent(Map<String, dynamic> event) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(event));
    }
  }

  void sendMessage(Message message) {
    _sendEvent({
      'type': 'message',
      'data': message.toJson(),
    });
  }

  // 发起语音通话
  void startVoiceCall(String conversationId, String participantId) {
    _sendEvent({
      'type': 'call',
      'callType': 'voice',
      'conversationId': conversationId,
      'participantId': participantId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 发起视频通话
  void startVideoCall(String conversationId, String participantId) {
    _sendEvent({
      'type': 'call',
      'callType': 'video',
      'conversationId': conversationId,
      'participantId': participantId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 接受通话
  void acceptCall(String conversationId, String callId) {
    _sendEvent({
      'type': 'call_response',
      'action': 'accept',
      'conversationId': conversationId,
      'callId': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 拒绝通话
  void rejectCall(String conversationId, String callId) {
    _sendEvent({
      'type': 'call_response',
      'action': 'reject',
      'conversationId': conversationId,
      'callId': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 结束通话
  void endCall(String conversationId, String callId) {
    _sendEvent({
      'type': 'call_response',
      'action': 'end',
      'conversationId': conversationId,
      'callId': callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void markMessageAsRead(String messageId, String conversationId) {
    _sendEvent({
      'type': 'read',
      'messageId': messageId,
      'conversationId': conversationId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void joinConversation(String conversationId) {
    _sendEvent({
      'type': 'join',
      'conversationId': conversationId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void leaveConversation(String conversationId) {
    _sendEvent({
      'type': 'leave',
      'conversationId': conversationId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void disconnect() {
    _isConnected = false;
    _stopHeartbeat();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _eventController.close();
  }
}