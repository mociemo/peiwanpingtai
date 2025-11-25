package com.playmate.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class WebSocketController {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * 处理客户端发送的消息
     */
    @MessageMapping("/chat.sendMessage")
    @SendTo("/topic/public")
    public Map<String, Object> sendMessage(Map<String, Object> message, Authentication authentication) {
        log.info("收到消息: {}", message);
        
        // 添加发送者信息和时间戳
        message.put("sender", authentication.getName());
        message.put("timestamp", LocalDateTime.now().toString());
        
        return message;
    }

    /**
     * 处理用户加入
     */
    @MessageMapping("/chat.addUser")
    @SendTo("/topic/public")
    public Map<String, Object> addUser(Map<String, Object> message, Authentication authentication) {
        log.info("用户加入: {}", authentication.getName());
        
        Map<String, Object> response = new HashMap<>();
        response.put("type", "user_joined");
        response.put("username", authentication.getName());
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }

    /**
     * 发送私人消息
     */
    @MessageMapping("/chat.privateMessage")
    public void sendPrivateMessage(Map<String, Object> message, Authentication authentication) {
        String recipient = (String) message.get("recipient");
        String content = (String) message.get("content");
        
        Map<String, Object> privateMessage = new HashMap<>();
        privateMessage.put("type", "private_message");
        privateMessage.put("sender", authentication.getName());
        privateMessage.put("content", content);
        privateMessage.put("timestamp", LocalDateTime.now().toString());
        
        // 发送给特定用户
        messagingTemplate.convertAndSendToUser(recipient != null ? recipient : "", "/queue/private", privateMessage);
        log.info("发送私人消息: {} -> {}", authentication.getName(), recipient);
    }

    /**
     * 系统通知
     */
    public void sendSystemNotification(String message, String... usernames) {
        Map<String, Object> notification = new HashMap<>();
        notification.put("type", "system_notification");
        notification.put("content", message);
        notification.put("timestamp", LocalDateTime.now().toString());
        
        if (usernames.length == 0) {
            // 广播给所有用户
            messagingTemplate.convertAndSend("/topic/system", notification);
        } else {
            // 发送给特定用户
            for (String username : usernames) {
                messagingTemplate.convertAndSendToUser(username != null ? username : "", "/queue/system", notification);
            }
        }
        
        log.info("发送系统通知: {}", message);
    }
}