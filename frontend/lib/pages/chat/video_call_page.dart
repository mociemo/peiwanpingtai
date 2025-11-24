import 'package:flutter/material.dart';

import '../../services/call_service.dart';

class VideoCallPage extends StatefulWidget {
  final String conversationId;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final bool isInitiator; // 是否是发起方

  const VideoCallPage({
    super.key,
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    this.isInitiator = true,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final bool _isConnected = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
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

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
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

  void _switchCamera() {
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
      body: Stack(
        children: [
          // 远程视频视图
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade900,
              child: _isConnected
                  ? const Center(
                      child: Text(
                        '远程视频',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: widget.participantAvatar.isNotEmpty
                                ? NetworkImage(widget.participantAvatar)
                                : null,
                            child: widget.participantAvatar.isEmpty
                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.participantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isConnected ? _formatDuration(_callDuration) : '连接中...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // 本地视频视图
          if (_isConnected)
            Positioned(
              top: 80,
              right: 20,
              width: 120,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isCameraOff
                      ? const Center(
                          child: Icon(
                            Icons.videocam_off,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                      : const Center(
                          child: Text(
                            '本地视频',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
            ),

          // 顶部工具栏
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _endCall,
                ),
                if (_isConnected)
                  IconButton(
                    icon: const Icon(Icons.switch_camera, color: Colors.white),
                    onPressed: _switchCamera,
                  ),
              ],
            ),
          ),

          // 底部控制栏
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 静音按钮
                FloatingActionButton(
                  heroTag: "mute",
                  onPressed: _toggleMute,
                  backgroundColor: _isMuted ? Colors.red : Colors.grey.shade700,
                  child: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                // 摄像头按钮
                FloatingActionButton(
                  heroTag: "camera",
                  onPressed: _toggleCamera,
                  backgroundColor: _isCameraOff ? Colors.red : Colors.grey.shade700,
                  child: Icon(
                    _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    color: Colors.white,
                  ),
                ),
                // 扬声器按钮
                FloatingActionButton(
                  heroTag: "speaker",
                  onPressed: _toggleSpeaker,
                  backgroundColor: _isSpeakerOn ? Colors.grey.shade700 : Colors.grey.shade700,
                  child: Icon(
                    _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    color: Colors.white,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}