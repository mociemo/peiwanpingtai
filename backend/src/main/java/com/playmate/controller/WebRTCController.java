package com.playmate.controller;

import com.playmate.service.WebRTCService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.HashMap;
import java.util.Map;

/**
 * WebRTC通话控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/webrtc")
@RequiredArgsConstructor
public class WebRTCController {
    
    private final WebRTCService webRTCService;
    
    /**
     * 发起通话
     */
    @PostMapping("/call")
    public ResponseEntity<Map<String, Object>> initiateCall(
            @RequestParam String toUserId,
            @RequestParam boolean isVideoCall,
            Principal principal) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String fromUserId = principal.getName();
            
            // 这里需要获取用户的WebSocket会话，简化处理
            // 实际应该从WebSocket管理器中获取
            // webRTCService.initiateCall(fromUserId, toUserId, isVideoCall, session);
            
            response.put("success", true);
            response.put("message", "通话发起成功");
            response.put("data", Map.of(
                "fromUserId", fromUserId,
                "toUserId", toUserId,
                "isVideoCall", isVideoCall
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("发起通话失败", e);
            response.put("success", false);
            response.put("message", "发起通话失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 接受通话
     */
    @PostMapping("/accept")
    public ResponseEntity<Map<String, Object>> acceptCall(
            @RequestParam String callId,
            Principal principal) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userId = principal.getName();
            
            // webRTCService.acceptCall(callId, userId, session);
            
            response.put("success", true);
            response.put("message", "通话接受成功");
            response.put("data", Map.of(
                "callId", callId,
                "userId", userId
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("接受通话失败", e);
            response.put("success", false);
            response.put("message", "接受通话失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 拒绝通话
     */
    @PostMapping("/reject")
    public ResponseEntity<Map<String, Object>> rejectCall(
            @RequestParam String callId,
            Principal principal) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userId = principal.getName();
            webRTCService.rejectCall(callId, userId);
            
            response.put("success", true);
            response.put("message", "通话拒绝成功");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("拒绝通话失败", e);
            response.put("success", false);
            response.put("message", "拒绝通话失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 结束通话
     */
    @PostMapping("/end")
    public ResponseEntity<Map<String, Object>> endCall(
            @RequestParam String callId,
            Principal principal) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userId = principal.getName();
            webRTCService.endCall(callId, userId);
            
            response.put("success", true);
            response.put("message", "通话结束成功");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("结束通话失败", e);
            response.put("success", false);
            response.put("message", "结束通话失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * 获取通话统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getCallStats() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            int activeCallCount = webRTCService.getActiveCallCount();
            int onlineUserCount = webRTCService.getOnlineUserCount();
            
            response.put("success", true);
            response.put("message", "获取统计信息成功");
            response.put("data", Map.of(
                "activeCallCount", activeCallCount,
                "onlineUserCount", onlineUserCount
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("获取统计信息失败", e);
            response.put("success", false);
            response.put("message", "获取统计信息失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}