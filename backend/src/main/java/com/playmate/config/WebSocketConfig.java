package com.playmate.config;

import com.playmate.handler.ChatWebSocketHandler;
import com.playmate.handler.WebRTCHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.NonNull;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

/**
 * WebSocket配置
 */
@Configuration
@EnableWebSocket
@RequiredArgsConstructor
@SuppressWarnings("null")
public class WebSocketConfig implements WebSocketConfigurer {
    
    private final WebRTCHandler webRTCHandler;
    private final ChatWebSocketHandler chatWebSocketHandler;
    
    @Override
    public void registerWebSocketHandlers(@NonNull WebSocketHandlerRegistry registry) {
        // 注册聊天WebSocket处理器
        registry.addHandler(chatWebSocketHandler, "/ws")
                .setAllowedOrigins("*") // 生产环境应该设置具体的域名
                .withSockJS(); // 启用SockJS支持
        
        // 注册WebRTC信令处理器
        registry.addHandler(webRTCHandler, "/ws/webrtc")
                .setAllowedOrigins("*"); // 生产环境应该设置具体的域名
    }
}