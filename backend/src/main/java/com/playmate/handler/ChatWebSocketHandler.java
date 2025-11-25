package com.playmate.handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 聊天WebSocket处理器
 */
@Slf4j
@Component
@RequiredArgsConstructor
@SuppressWarnings("null")
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final ObjectMapper objectMapper;
    
    // 存储所有活跃的WebSocket会话
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    // 存储用户ID到会话的映射
    private final Map<String, String> userSessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(@NonNull WebSocketSession session) throws Exception {
        log.info("聊天WebSocket连接建立: {}", session.getId());
        
        // 从查询参数中获取用户ID和token
        try {
            java.net.URI uri = session.getUri();
            String query = uri != null ? uri.getQuery() : null;
            if (query != null && !query.isEmpty()) {
                String[] params = query.split("&");
                String userId = null;
                String token = null;
                
                for (String param : params) {
                    if (param.startsWith("userId=")) {
                        userId = param.substring(7);
                    } else if (param.startsWith("token=")) {
                        token = param.substring(6);
                    }
                }
                
                if (userId != null && token != null) {
                    sessions.put(session.getId(), session);
                    userSessions.put(userId, session.getId());
                    
                    // 发送连接成功消息
                    Map<String, Object> connectMessage = new HashMap<>();
                    connectMessage.put("type", "connect");
                    connectMessage.put("message", "连接成功");
                    connectMessage.put("userId", userId);
                    connectMessage.put("timestamp", LocalDateTime.now().toString());
                    
                    sendMessage(session, connectMessage);
                    
                    // 广播用户加入消息
                    Map<String, Object> joinMessage = new HashMap<>();
                    joinMessage.put("type", "user_joined");
                    joinMessage.put("userId", userId);
                    joinMessage.put("timestamp", LocalDateTime.now().toString());
                    
                    broadcastToAll(joinMessage);
                    
                    log.info("用户 {} 已连接到聊天", userId);
                }
            }
        } catch (Exception e) {
            log.warn("获取WebSocket查询参数失败: {}", e.getMessage());
        }
    }

    @Override
    protected void handleTextMessage(@NonNull WebSocketSession session, @NonNull TextMessage message) throws Exception {
        log.info("收到聊天消息: {}", message.getPayload());
        
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> messageData = objectMapper.readValue(message.getPayload(), Map.class);
            String userId = getUserIdBySession(session.getId());
            
            if (userId != null) {
                messageData.put("sender", userId);
                messageData.put("timestamp", LocalDateTime.now().toString());
                
                String type = (String) messageData.get("type");
                
                if ("message".equals(type)) {
                    // 广播消息给所有用户
                    broadcastToAll(messageData);
                } else if ("private_message".equals(type)) {
                    // 发送私人消息
                    String recipient = (String) messageData.get("recipient");
                    if (recipient != null) {
                        sendToUser(recipient, messageData);
                    }
                } else if ("ping".equals(type)) {
                    // 心跳响应
                    Map<String, Object> pongMessage = new HashMap<>();
                    pongMessage.put("type", "pong");
                    pongMessage.put("timestamp", LocalDateTime.now().toString());
                    sendMessage(session, pongMessage);
                }
            }
        } catch (Exception e) {
            log.error("处理聊天消息失败", e);
        }
    }

    @Override
    public void afterConnectionClosed(@NonNull WebSocketSession session, @NonNull CloseStatus status) throws Exception {
        log.info("聊天WebSocket连接关闭: {}", session.getId());
        
        String userId = getUserIdBySession(session.getId());
        if (userId != null) {
            sessions.remove(session.getId());
            userSessions.remove(userId);
            
            // 广播用户离开消息
            Map<String, Object> leaveMessage = new HashMap<>();
            leaveMessage.put("type", "user_left");
            leaveMessage.put("userId", userId);
            leaveMessage.put("timestamp", LocalDateTime.now().toString());
            
            broadcastToAll(leaveMessage);
            
            log.info("用户 {} 已断开聊天连接", userId);
        }
    }

    /**
     * 发送消息给指定会话
     */
    private void sendMessage(WebSocketSession session, Map<String, Object> message) {
        try {
            if (session.isOpen()) {
                @SuppressWarnings("null")
                String jsonMessage = objectMapper.writeValueAsString(message);
                session.sendMessage(new TextMessage(jsonMessage));
            }
        } catch (Exception e) {
            log.error("发送消息失败", e);
        }
    }

    /**
     * 广播消息给所有用户
     */
    private void broadcastToAll(Map<String, Object> message) {
        sessions.values().forEach(session -> sendMessage(session, message));
    }

    /**
     * 发送消息给指定用户
     */
    private void sendToUser(String userId, Map<String, Object> message) {
        String sessionId = userSessions.get(userId);
        if (sessionId != null) {
            WebSocketSession session = sessions.get(sessionId);
            if (session != null) {
                sendMessage(session, message);
            }
        }
    }

    /**
     * 根据会话ID获取用户ID
     */
    private String getUserIdBySession(String sessionId) {
        for (Map.Entry<String, String> entry : userSessions.entrySet()) {
            if (entry.getValue().equals(sessionId)) {
                return entry.getKey();
            }
        }
        return null;
    }

    /**
     * 获取在线用户数量
     */
    public int getOnlineUserCount() {
        return userSessions.size();
    }
}