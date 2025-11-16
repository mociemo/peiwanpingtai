import 'package:flutter/material.dart';

import '../../services/call_service.dart';

class VoiceCallPage extends StatefulWidget {
  final String conversationId;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final bool isInitiator; // 是否是发起方

  const VoiceCallPage({
    super.key,
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    this.isInitiator = true,
  });

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  final bool _isConnected = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  final Duration _callDuration = Duration.zero;
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  void _initializeCall() {
    if (widget.isInitiator) {
      _makeCall();
    } else {
      _receiveCall();
    }
  }

  void _makeCall() {
    setState(() {
      _callStartTime = DateTime.now();
    });
    _startCallTimer();
  }

  void _receiveCall() {
    setState(() {
      _callStartTime = DateTime.now();
    });
    _startCallTimer();
  }

  void _startCallTimer() {
    if (_callStartTime != null) {
      debugPrint('Call started at: $_callStartTime');
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  void _endCall() {
    // 使用CallService结束通话
    CallService().endCall();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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
                    onPressed: _endCall,
                  ),
                  Text(
                    '语音通话',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    onPressed: () {},
                  ),
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
                Hero(
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
                Text(
                  _isConnected ? _formatDuration(_callDuration) : '连接中...',
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
                ),

                const SizedBox(height: 40),

                // 音波动画（可选）
                if (_isConnected && !_isMuted)
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 4,
                          height: 20.0 + (index % 2) * 20.0,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (_isMuted)
                  const Icon(Icons.mic_off, color: Colors.white, size: 40),
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
                  // 静音按钮
                  FloatingActionButton(
                    heroTag: "mute",
                    onPressed: _toggleMute,
                    backgroundColor: _isMuted
                        ? Colors.red
                        : Colors.grey.shade700,
                    child: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // 扬声器按钮
                  FloatingActionButton(
                    heroTag: "speaker",
                    onPressed: _toggleSpeaker,
                    backgroundColor: _isSpeakerOn
                        ? Colors.grey.shade700
                        : Colors.grey.shade700,
                    child: Icon(
                      _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // 结束通话按钮
                  FloatingActionButton(
                    heroTag: "end",
                    onPressed: _endCall,
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Icons.call_end,
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
