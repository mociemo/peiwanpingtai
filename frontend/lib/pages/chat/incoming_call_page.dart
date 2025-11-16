import 'package:flutter/material.dart';

import '../../services/call_service.dart';

class IncomingCallPage extends StatefulWidget {
  final String conversationId;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final bool isVideoCall; // 是否是视频通话

  const IncomingCallPage({
    super.key,
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    this.isVideoCall = false,
  });

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _callId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 获取callId
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _callId = args?['callId'];

    // 自动拒绝通话（30秒后）
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _rejectCall();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _acceptCall() {
    // 使用CallService接受通话
    CallService().acceptCall(
      widget.conversationId,
      _callId ?? '',
      widget.isVideoCall,
    );
  }

  void _rejectCall() {
    // 使用CallService拒绝通话
    CallService().rejectCall(widget.conversationId, _callId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // 顶部工具栏
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _rejectCall,
                  ),
                  Text(
                    widget.isVideoCall ? '视频来电' : '语音来电',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 48), // 平衡布局
                ],
              ),
            ),
          ),

          // 中间内容区域
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 用户头像
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Hero(
                        tag: 'avatar_${widget.participantId}',
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: widget.participantAvatar.isNotEmpty
                              ? NetworkImage(widget.participantAvatar)
                              : null,
                          child: widget.participantAvatar.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 用户名
                Text(
                  widget.participantName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                // 通话状态
                const Text(
                  '来电中...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),

                const SizedBox(height: 40),

                // 通话类型图标
                Icon(
                  widget.isVideoCall ? Icons.videocam : Icons.phone,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),
          ),

          // 底部控制栏
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 拒绝按钮
                  FloatingActionButton(
                    heroTag: "reject",
                    onPressed: _rejectCall,
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // 接听按钮
                  FloatingActionButton(
                    heroTag: "accept",
                    onPressed: _acceptCall,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
