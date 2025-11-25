import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

/// WebRTC服务类
/// 处理视频/语音通话的WebRTC连接和信令
class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  WebSocketChannel? _channel;
  String? _currentUserId;
  String? _currentCallId;
  bool _isVideoCall = false;
  
  // 事件回调
  Function(String callId, String fromUserId, bool isVideoCall)? onCallInvite;
  Function(String callId, String userId)? onCallAccepted;
  Function(String callId, String userId)? onCallRejected;
  Function(String callId, String endedBy, int duration)? onCallEnded;
  Function(String callId, String fromUserId, String signalType, dynamic signalData)? onSignaling;
  Function(String message)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  /// 连接WebSocket
  Future<bool> connect(String userId) async {
    try {
      _currentUserId = userId;
      
      final uri = Uri.parse('${ApiConfig.wsUrl}/webrtc?userId=$userId');
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('WebSocket错误: $error');
          onError?.call('连接错误: $error');
        },
        onDone: () {
          debugPrint('WebSocket连接关闭');
          onDisconnected?.call();
        },
      );
      
      onConnected?.call();
      return true;
    } catch (e) {
      debugPrint('WebSocket连接失败: $e');
      onError?.call('连接失败: $e');
      return false;
    }
  }

  /// 断开连接
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _currentUserId = null;
    _currentCallId = null;
  }

  /// 发起通话
  Future<bool> initiateCall(String toUserId, bool isVideoCall) async {
    if (_channel == null || _currentUserId == null) {
      onError?.call('未连接到服务器');
      return false;
    }

    try {
      _isVideoCall = isVideoCall;
      
      final message = {
        'type': 'initiate_call',
        'fromUserId': _currentUserId,
        'toUserId': toUserId,
        'isVideoCall': isVideoCall,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel!.sink.add(json.encode(message));
      return true;
    } catch (e) {
      onError?.call('发起通话失败: $e');
      return false;
    }
  }

  /// 接受通话
  Future<bool> acceptCall(String callId) async {
    if (_channel == null || _currentUserId == null) {
      return false;
    }

    try {
      _currentCallId = callId;
      
      final message = {
        'type': 'accept_call',
        'callId': callId,
        'userId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel!.sink.add(json.encode(message));
      return true;
    } catch (e) {
      onError?.call('接受通话失败: $e');
      return false;
    }
  }

  /// 拒绝通话
  Future<bool> rejectCall(String callId) async {
    if (_channel == null || _currentUserId == null) {
      return false;
    }

    try {
      final message = {
        'type': 'reject_call',
        'callId': callId,
        'userId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel!.sink.add(json.encode(message));
      return true;
    } catch (e) {
      onError?.call('拒绝通话失败: $e');
      return false;
    }
  }

  /// 结束通话
  Future<bool> endCall() async {
    if (_channel == null || _currentUserId == null || _currentCallId == null) {
      return false;
    }

    try {
      final message = {
        'type': 'end_call',
        'callId': _currentCallId,
        'userId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel!.sink.add(json.encode(message));
      _currentCallId = null;
      return true;
    } catch (e) {
      onError?.call('结束通话失败: $e');
      return false;
    }
  }

  /// 发送信令消息
  Future<bool> sendSignaling(String signalType, dynamic signalData) async {
    if (_channel == null || _currentUserId == null || _currentCallId == null) {
      return false;
    }

    try {
      final message = {
        'type': 'signaling',
        'callId': _currentCallId,
        'userId': _currentUserId,
        'signalType': signalType,
        'signalData': signalData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _channel!.sink.add(json.encode(message));
      return true;
    } catch (e) {
      onError?.call('发送信令失败: $e');
      return false;
    }
  }

  /// 处理接收到的消息
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final type = data['type'];

      switch (type) {
        case 'call_invite':
          _handleCallInvite(data);
          break;
        case 'call_accepted':
          _handleCallAccepted(data);
          break;
        case 'call_rejected':
          _handleCallRejected(data);
          break;
        case 'call_ended':
          _handleCallEnded(data);
          break;
        case 'signaling':
          _handleSignaling(data);
          break;
        case 'error':
          onError?.call(data['message'] ?? '未知错误');
          break;
        default:
          debugPrint('未知消息类型: $type');
      }
    } catch (e) {
      debugPrint('处理消息失败: $e');
      onError?.call('消息处理失败: $e');
    }
  }

  void _handleCallInvite(Map<String, dynamic> data) {
    final callId = data['callId'];
    final fromUserId = data['fromUserId'];
    final isVideoCall = data['isVideoCall'] ?? false;
    
    onCallInvite?.call(callId, fromUserId, isVideoCall);
  }

  void _handleCallAccepted(Map<String, dynamic> data) {
    final callId = data['callId'];
    final userId = data['userId'];
    
    _currentCallId = callId;
    onCallAccepted?.call(callId, userId);
  }

  void _handleCallRejected(Map<String, dynamic> data) {
    final callId = data['callId'];
    final userId = data['userId'];
    
    _currentCallId = null;
    onCallRejected?.call(callId, userId);
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    final callId = data['callId'];
    final endedBy = data['endedBy'];
    final duration = data['duration'] ?? 0;
    
    _currentCallId = null;
    onCallEnded?.call(callId, endedBy, duration);
  }

  void _handleSignaling(Map<String, dynamic> data) {
    final callId = data['callId'];
    final fromUserId = data['fromUserId'];
    final signalType = data['signalType'];
    final signalData = data['signalData'];
    
    onSignaling?.call(callId, fromUserId, signalType, signalData);
  }

  /// 获取当前状态
  bool get isConnected => _channel != null;
  String? get currentUserId => _currentUserId;
  String? get currentCallId => _currentCallId;
  bool get isVideoCall => _isVideoCall;
  bool get isInCall => _currentCallId != null;
}