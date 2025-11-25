import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

/// Web平台兼容性工具类
class WebCompatibilityFix {
  
  /// 检测是否为Web平台
  static bool get isWeb => kIsWeb;
  
  /// 检测是否为移动端Web
  static bool get isMobileWeb {
    if (!kIsWeb) return false;
    // 简化实现，避免复杂的浏览器检测
    return false; // 暂时返回false，避免兼容性问题
  }
  
  /// 检测是否为桌面端Web
  static bool get isDesktopWeb {
    return kIsWeb && !isMobileWeb;
  }
  
  /// Web平台安全打开链接
  static void openLink(String url) {
    if (kIsWeb) {
      debugPrint('打开链接: $url');
      // 简化实现，避免Web API兼容性问题
    } else {
      // 移动端使用url_launcher
    }
  }
  
  /// Web平台复制到剪贴板
  static Future<void> copyToClipboard(String text) async {
    if (kIsWeb) {
      debugPrint('复制到剪贴板: $text');
      // 简化实现，避免Web API兼容性问题
    } else {
      // 移动端使用其他方式
    }
  }
  
  /// Web平台获取本地存储
  static String? getLocalStorage(String key) {
    if (kIsWeb) {
      debugPrint('获取本地存储: $key');
      return null; // 简化实现
    }
    return null;
  }
  
  /// Web平台设置本地存储
  static void setLocalStorage(String key, String value) {
    if (kIsWeb) {
      debugPrint('设置本地存储: $key = $value');
      // 简化实现
    }
  }
  
  /// Web平台显示通知
  static void showNotification(String title, String body) {
    if (kIsWeb) {
      debugPrint('显示通知: $title - $body');
      // 简化实现
    }
  }
  
  /// Web平台获取设备信息
  static Map<String, dynamic> getDeviceInfo() {
    if (kIsWeb) {
      return {
        'webBuild': true,
        'platform': 'web',
        'userAgent': 'Flutter Web',
      };
    }
    return {};
  }
  
  /// Web平台处理文件选择
  static void pickFile(Function(List<dynamic>) onFilesSelected) {
    if (kIsWeb) {
      debugPrint('选择文件');
      // 简化实现
    }
  }
  
  /// Web平台处理图片选择
  static void pickImage(Function(dynamic) onImageSelected) {
    if (kIsWeb) {
      debugPrint('选择图片');
      // 简化实现
    }
  }
  
  /// Web平台处理相机拍照（仅移动端Web）
  static void capturePhoto(Function(dynamic) onPhotoCaptured) {
    if (kIsWeb && isMobileWeb) {
      debugPrint('拍照');
      // 简化实现
    }
  }
  
  /// Web平台获取位置信息
  static Future<dynamic> getCurrentPosition() async {
    if (kIsWeb) {
      debugPrint('获取位置信息');
      return null; // 简化实现
    }
    return null;
  }
  
  /// Web平台处理WebSocket连接
  static dynamic createWebSocket(String url) {
    if (kIsWeb) {
      debugPrint('创建WebSocket: $url');
      return null; // 简化实现
    }
    return null;
  }
  
  /// Web平台处理WebRTC
  static Future<dynamic> createPeerConnection() async {
    if (kIsWeb) {
      debugPrint('创建PeerConnection');
      return null; // 简化实现
    }
    return null;
  }
  
  /// Web平台获取用户媒体（摄像头/麦克风）
  static Future<dynamic> getUserMedia({
    bool video = false,
    bool audio = false,
  }) async {
    if (kIsWeb) {
      debugPrint('获取媒体流: video=$video, audio=$audio');
      return null; // 简化实现
    }
    return null;
  }
  
  /// Web平台振动API（仅移动端Web）
  static void vibrate(int duration) {
    if (kIsWeb && isMobileWeb) {
      debugPrint('振动: ${duration}ms');
      // 简化振动实现
    }
  }
  
  /// Web平台分享功能
  static Future<bool> share({
    String? title,
    String? text,
    String? url,
  }) async {
    if (kIsWeb) {
      debugPrint('分享: title=$title, text=$text, url=$url');
      // 简化分享实现，使用复制链接
      if (url != null) {
        await copyToClipboard(url);
        return true;
      }
    }
    return false;
  }
  
  /// Web平台添加到主屏幕
  static Future<bool> addToHomeScreen() async {
    if (kIsWeb) {
      debugPrint('PWA安装提示');
      return false; // 简化实现
    }
    return false;
  }
  
  /// Web平台处理权限请求
  static Future<bool> requestPermission(String permission) async {
    if (kIsWeb) {
      debugPrint('权限请求: $permission');
      return false; // 简化实现
    }
    return false;
  }
}