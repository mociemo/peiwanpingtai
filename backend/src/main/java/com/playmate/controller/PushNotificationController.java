package com.playmate.controller;

import com.playmate.service.PushNotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 推送通知控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/push")
@RequiredArgsConstructor
public class PushNotificationController {
    
    private final PushNotificationService pushNotificationService;
    
    /**
     * 推送给单个用户
     */
    @PostMapping("/user")
    public ResponseEntity<Map<String, Object>> pushToUser(
            @RequestParam String userId,
            @RequestParam String title,
            @RequestParam String content,
            @RequestBody(required = false) Map<String, String> extras) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = pushNotificationService.pushToUser(userId, title, content, extras);
            
            response.put("success", success);
            response.put("message", success ? "推送成功" : "推送失败");
            response.put("data", Map.of(
                "userId", userId,
                "title", title,
                "content", content
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("推送失败", e);
            response.put("success", false);
            response.put("message", "推送失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 推送给多个用户
     */
    @PostMapping("/users")
    public ResponseEntity<Map<String, Object>> pushToUsers(
            @RequestParam String[] userIds,
            @RequestParam String title,
            @RequestParam String content,
            @RequestBody(required = false) Map<String, String> extras) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = pushNotificationService.pushToUsers(userIds, title, content, extras);
            
            response.put("success", success);
            response.put("message", success ? "群推送成功" : "群推送失败");
            response.put("data", Map.of(
                "userCount", userIds.length,
                "title", title,
                "content", content
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("群推送失败", e);
            response.put("success", false);
            response.put("message", "群推送失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 推送给所有用户
     */
    @PostMapping("/all")
    public ResponseEntity<Map<String, Object>> pushToAll(
            @RequestParam String title,
            @RequestParam String content,
            @RequestBody(required = false) Map<String, String> extras) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = pushNotificationService.pushToAll(title, content, extras);
            
            response.put("success", success);
            response.put("message", success ? "全量推送成功" : "全量推送失败");
            response.put("data", Map.of(
                "title", title,
                "content", content
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("全量推送失败", e);
            response.put("success", false);
            response.put("message", "全量推送失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 推送新消息通知
     */
    @PostMapping("/message")
    public ResponseEntity<Map<String, Object>> pushNewMessage(
            @RequestParam String toUserId,
            @RequestParam String fromUserName,
            @RequestParam String messageContent) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = pushNotificationService.pushNewMessage(toUserId, fromUserName, messageContent);
            
            response.put("success", success);
            response.put("message", success ? "消息推送成功" : "消息推送失败");
            response.put("data", Map.of(
                "toUserId", toUserId,
                "fromUserName", fromUserName
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("消息推送失败", e);
            response.put("success", false);
            response.put("message", "消息推送失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 推送订单状态变更
     */
    @PostMapping("/order")
    public ResponseEntity<Map<String, Object>> pushOrderStatus(
            @RequestParam String userId,
            @RequestParam String orderNo,
            @RequestParam String status) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = pushNotificationService.pushOrderStatusChange(userId, orderNo, status);
            
            response.put("success", success);
            response.put("message", success ? "订单状态推送成功" : "订单状态推送失败");
            response.put("data", Map.of(
                "userId", userId,
                "orderNo", orderNo,
                "status", status
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("订单状态推送失败", e);
            response.put("success", false);
            response.put("message", "订单状态推送失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 推送通话邀请
     */
    @PostMapping("/call")
    public ResponseEntity<Map<String, Object>> pushCallInvite(
            @RequestParam String toUserId,
            @RequestParam String fromUserName,
            @RequestParam boolean isVideoCall) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = pushNotificationService.pushCallInvite(toUserId, fromUserName, isVideoCall);
            
            response.put("success", success);
            response.put("message", success ? "通话邀请推送成功" : "通话邀请推送失败");
            response.put("data", Map.of(
                "toUserId", toUserId,
                "fromUserName", fromUserName,
                "isVideoCall", isVideoCall
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("通话邀请推送失败", e);
            response.put("success", false);
            response.put("message", "通话邀请推送失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 推送系统通知
     */
    @PostMapping("/system")
    public ResponseEntity<Map<String, Object>> pushSystemNotification(
            @RequestParam String title,
            @RequestParam String content) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            boolean success = pushNotificationService.pushSystemNotification(title, content);
            
            response.put("success", success);
            response.put("message", success ? "系统通知推送成功" : "系统通知推送失败");
            response.put("data", Map.of(
                "title", title,
                "content", content
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("系统通知推送失败", e);
            response.put("success", false);
            response.put("message", "系统通知推送失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 获取推送统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getPushStats() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Map<String, Object> stats = pushNotificationService.getPushStats();
            
            response.put("success", true);
            response.put("message", "获取推送统计成功");
            response.put("data", stats);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("获取推送统计失败", e);
            response.put("success", false);
            response.put("message", "获取推送统计失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}