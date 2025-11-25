package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.Message;
import com.playmate.entity.User;
import com.playmate.service.MessageService;
import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;
    private final UserService userService;

    /**
     * 获取用户的对话列表
     */
    @GetMapping("/conversations")
    public ResponseEntity<ApiResponse<List<Message>>> getConversations(Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            
            List<Message> conversations = messageService.getUserConversations(userId);
            
            // 隐藏敏感信息
            conversations.forEach(msg -> msg.setIsRead(null));
            
            return ResponseEntity.ok(ApiResponse.success(conversations));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取对话列表失败: " + e.getMessage()));
        }
    }

    /**
     * 获取对话中的消息
     */
    @GetMapping("/conversations/{conversationId}")
    public ResponseEntity<ApiResponse<List<Message>>> getConversationMessages(
            @PathVariable String conversationId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            
            List<Message> messages = messageService.getConversationMessages(conversationId, userId);
            
            // 标记消息为已读
            messageService.markMessagesAsRead(userId, conversationId);
            
            return ResponseEntity.ok(ApiResponse.success(messages));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取消息失败: " + e.getMessage()));
        }
    }

    /**
     * 发送消息
     */
    @PostMapping("/send")
    public ResponseEntity<ApiResponse<Message>> sendMessage(
            @RequestBody Map<String, Object> request,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            User sender = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            if (sender == null) {
                throw new IllegalStateException("用户不存在");
            }
            Long senderId = sender.getId();
            if (senderId == null) {
                throw new IllegalStateException("发送者ID不能为空");
            }
            
            Object recipientIdObj = request.get("recipientId");
            Long recipientId = recipientIdObj != null ? Long.valueOf(recipientIdObj.toString()) : 0L;
            String content = (String) request.get("content");
            Message.MessageType type = Message.MessageType.TEXT; // 默认文本消息
            
            if (request.containsKey("type")) {
                type = Message.MessageType.valueOf(request.get("type").toString());
            }
            
            Message message = messageService.sendMessage(
                senderId, 
                recipientId, 
                content != null ? content : "", 
                type
            );
            
            // 隐藏敏感信息
            message.setIsRead(false);
            
            return ResponseEntity.ok(ApiResponse.success("发送成功", message));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("发送失败: " + e.getMessage()));
        }
    }

    /**
     * 获取未读消息数量
     */
    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUnreadCount(Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            
            Long unreadCount = messageService.getUnreadMessageCount(userId);
            
            return ResponseEntity.ok(ApiResponse.success(Map.of(
                "unreadCount", unreadCount
            )));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取未读消息数量失败: " + e.getMessage()));
        }
    }

    /**
     * 标记消息为已读
     */
    @PostMapping("/conversations/{conversationId}/read")
    public ResponseEntity<ApiResponse<String>> markAsRead(
            @PathVariable String conversationId,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            
            messageService.markMessagesAsRead(userId, conversationId);
            
            return ResponseEntity.ok(ApiResponse.success("标记成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("标记失败: " + e.getMessage()));
        }
    }

    /**
     * 发送位置消息
     */
    @PostMapping("/conversations/{conversationId}/messages")
    public ResponseEntity<ApiResponse<Message>> sendMessageToConversation(
            @PathVariable @NonNull String conversationId,
            @RequestBody @NonNull Map<String, Object> request,
            @NonNull Authentication authentication) {
        try {
            if (conversationId == null || request == null || authentication == null) {
                throw new IllegalArgumentException("参数不能为空");
            }
            
            String username = authentication.getName();
            User sender = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            if (sender == null) {
                throw new IllegalStateException("用户不存在");
            }
            Long senderId = sender.getId();
            if (senderId == null) {
                throw new IllegalStateException("发送者ID不能为空");
            }
            
            String content = (String) request.get("content");
            Message.MessageType type = Message.MessageType.valueOf(request.get("type").toString());
            
            // 处理位置消息
            if (type == Message.MessageType.LOCATION) {
                Double latitude = ((Number) request.get("latitude")).doubleValue();
                Double longitude = ((Number) request.get("longitude")).doubleValue();
                String address = (String) request.get("address");
                
                content = String.format("位置: %s (%.6f, %.6f)", address, latitude, longitude);
            }
            
            Message message = messageService.sendMessageToConversation(
                conversationId, 
                senderId, 
                content, 
                type
            );
            
            // 隐藏敏感信息
            message.setIsRead(false);
            
            return ResponseEntity.ok(ApiResponse.success("发送成功", message));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("发送失败: " + e.getMessage()));
        }
    }

    /**
     * 搜索用户
     */
    @GetMapping("/users/search")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> searchUsers(
            @RequestParam String keyword) {
        try {
            List<Map<String, Object>> users = userService.searchUsers(keyword);
            return ResponseEntity.ok(ApiResponse.success(users));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("搜索失败: " + e.getMessage()));
        }
    }
}