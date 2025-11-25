package com.playmate.config;

// 临时禁用WebSocket配置进行调试
// @Configuration
// @EnableWebSocket
// @RequiredArgsConstructor
// @SuppressWarnings("null")
// public class WebSocketConfig implements WebSocketConfigurer {
//     
//     private final WebRTCHandler webRTCHandler;
//     private final ChatWebSocketHandler chatWebSocketHandler;
//     
//     @Override
//     public void registerWebSocketHandlers(@NonNull WebSocketHandlerRegistry registry) {
//         // 注册聊天WebSocket处理器
//         registry.addHandler(chatWebSocketHandler, "/ws")
//                 .setAllowedOrigins("*") // 生产环境应该设置具体的域名
//                 .withSockJS(); // 启用SockJS支持
//         
//         // 注册WebRTC信令处理器
//         registry.addHandler(webRTCHandler, "/ws/webrtc")
//                 .setAllowedOrigins("*"); // 生产环境应该设置具体的域名
//     }
// }