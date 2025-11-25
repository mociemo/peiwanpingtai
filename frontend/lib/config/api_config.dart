/// API配置类
/// 本地服务器配置
class ApiConfig {
  // 本地服务器地址
  static const String baseUrl = 'http://localhost:8888';
  
  // API路径
  static String get apiBaseUrl => '$baseUrl/api';
  
  // WebSocket路径
  static String get wsBaseUrl => 'ws://localhost:8888/ws';
  static String get wsUrl => 'ws://localhost:8888';
  
  // 超时设置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API端点
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userInfoEndpoint = '/user/info';
  static const String postsEndpoint = '/posts';
  static const String ordersEndpoint = '/orders';
  static const String paymentEndpoint = '/payment';
  static const String chatEndpoint = '/chat';
  
  // 新增API端点
  static const String gameCategoriesEndpoint = '/game-categories';
  static const String activitiesEndpoint = '/activities';
  static const String pushEndpoint = '/push';
  static const String webrtcEndpoint = '/webrtc';
}
