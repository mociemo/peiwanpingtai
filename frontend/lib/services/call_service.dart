import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../utils/navigator_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  String? _currentCallId;
  String? _currentConversationId;
  bool _isInCall = false;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;

  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;
  String? get currentConversationId => _currentConversationId;
  Duration get callDuration => _callDuration;

  // 发起语音通话
  Future<void> startVoiceCall(String conversationId, String participantId) async {
    if (_isInCall) {
      debugPrint('已经在通话中，无法发起新的通话');
      return;
    }

    _currentCallId = 'call_${DateTime.now().millisecondsSinceEpoch}';
    _currentConversationId = conversationId;

    // 发送通话请求
    WebSocketService.instance.startVoiceCall(conversationId, participantId);

    // 导航到语音通话页面
    await NavigatorService.pushNamed('/chat/$conversationId/voice');
  }

  // 发起视频通话
  Future<void> startVideoCall(String conversationId, String participantId) async {
    if (_isInCall) {
      debugPrint('已经在通话中，无法发起新的通话');
      return;
    }

    _currentCallId = 'call_${DateTime.now().millisecondsSinceEpoch}';
    _currentConversationId = conversationId;

    // 发送通话请求
    WebSocketService.instance.startVideoCall(conversationId, participantId);

    // 导航到视频通话页面
    await NavigatorService.pushNamed('/chat/$conversationId/video');
  }

  // 接受通话
  Future<void> acceptCall(String conversationId, String callId, bool isVideo) async {
    if (_isInCall) {
      debugPrint('已经在通话中，无法接受新的通话');
      return;
    }

    _currentCallId = callId;
    _currentConversationId = conversationId;
    _isInCall = true;

    // 发送接受通话响应
    WebSocketService.instance.acceptCall(conversationId, callId);

    // 导航到通话页面
    if (isVideo) {
      await NavigatorService.pushNamed('/chat/$conversationId/video');
    } else {
      await NavigatorService.pushNamed('/chat/$conversationId/voice');
    }
  }

  // 拒绝通话
  void rejectCall(String conversationId, String callId) {
    // 发送拒绝通话响应
    WebSocketService.instance.rejectCall(conversationId, callId);

    // 返回到上一页
    NavigatorService.pop();
  }

  // 结束通话
  void endCall() {
    if (!_isInCall) return;

    // 发送结束通话响应
    if (_currentCallId != null && _currentConversationId != null) {
      WebSocketService.instance.endCall(_currentConversationId!, _currentCallId!);
    }

    // 停止计时器
    _callTimer?.cancel();
    _callTimer = null;

    // 重置状态
    _isInCall = false;
    _currentCallId = null;
    _currentConversationId = null;
    _callDuration = Duration.zero;

    // 返回到上一页
    NavigatorService.pop();
  }

  // 开始计时
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
    });
  }

  // 处理通话响应
  void handleCallResponse(Map<String, dynamic> event) {
    final action = event['action'] ?? '';
    final callId = event['callId'] ?? '';

    // 只处理当前通话的响应
    if (callId != _currentCallId) return;

    switch (action) {
      case 'accept':
        // 对方接受了通话
        _isInCall = true;
        _startCallTimer();
        break;
      case 'reject':
        // 对方拒绝了通话
        NavigatorService.pop();
        break;
      case 'end':
        // 通话结束
        endCall();
        break;
    }
  }
}