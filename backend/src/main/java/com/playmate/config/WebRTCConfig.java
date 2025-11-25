package com.playmate.config;

import com.playmate.handler.WebRTCHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

/**
 * WebRTC WebSocket配置
 */
@Configuration
@EnableWebSocket
@RequiredArgsConstructor
public class WebRTCConfig implements WebSocketConfigurer {
    
    private final WebRTCHandler webRTCHandler;
    
    @Value("${webrtc.websocket.path:/webrtc}")
    private String websocketPath;
    
    @Value("${webrtc.websocket.allowed-origins:*}")
    private String[] allowedOrigins;
    
    @Override
    @SuppressWarnings("null")
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(webRTCHandler, websocketPath)
                .setAllowedOrigins(allowedOrigins)
                .withSockJS(); // 启用SockJS支持，提高兼容性
    }
}