/// API配置类
/// 本地服务器配置
class ApiConfig {
  // 本地服务器地址
  static const String baseUrl = 'http://localhost:7777';
  
  // API路径
  static String get apiBaseUrl => '$baseUrl/api';
  
  // WebSocket路径
  static String get wsBaseUrl => 'ws://localhost:7777/ws';
  
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
}
