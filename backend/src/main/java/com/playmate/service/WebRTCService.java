package com.playmate.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebRTC信令服务
 * 处理视频/语音通话的信令交互
 */
@Slf4j
@Service
@RequiredArgsConstructor
@SuppressWarnings("null")
public class WebRTCService {
    
    private final ObjectMapper objectMapper;
    
    // 存储通话会话信息
    private final Map<String, CallSession> activeCalls = new ConcurrentHashMap<>();
    
    // 存储用户会话映射
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    
    /**
     * 发起通话
     */
    public void initiateCall(String fromUserId, String toUserId, boolean isVideoCall, 
                           WebSocketSession fromSession) throws IOException {
        String callId = generateCallId(fromUserId, toUserId);
        
        CallSession callSession = CallSession.builder()
                .callId(callId)
                .fromUserId(fromUserId)
                .toUserId(toUserId)
                .isVideoCall(isVideoCall)
                .status("calling")
                .startTime(System.currentTimeMillis())
                .build();
        
        activeCalls.put(callId, callSession);
        userSessions.put(fromUserId, fromSession);
        
        // 发送通话邀请给目标用户
        WebSocketSession toSession = userSessions.get(toUserId);
        if (toSession != null && toSession.isOpen()) {
            Map<String, Object> inviteMessage = Map.of(
                "type", "call_invite",
                "callId", callId,
                "fromUserId", fromUserId,
                "toUserId", toUserId,
                "isVideoCall", isVideoCall,
                "timestamp", System.currentTimeMillis()
            );
            
            String message = objectMapper.writeValueAsString(inviteMessage);
            toSession.sendMessage(new TextMessage(message));
            log.info("通话邀请已发送: {} -> {}", fromUserId, toUserId);
        } else {
            log.warn("目标用户不在线: {}", toUserId);
            sendCallEndMessage(fromUserId, callId, "对方不在线");
        }
    }
    
    /**
     * 接受通话
     */
    public void acceptCall(String callId, String userId, WebSocketSession userSession) throws IOException {
        CallSession callSession = activeCalls.get(callId);
        if (callSession == null) {
            log.warn("通话会话不存在: {}", callId);
            return;
        }
        
        if (!callSession.getToUserId().equals(userId)) {
            log.warn("用户无权接受此通话: {}", userId);
            return;
        }
        
        callSession.setStatus("accepted");
        userSessions.put(userId, userSession);
        
        // 通知发起方通话已接受
        WebSocketSession fromSession = userSessions.get(callSession.getFromUserId());
        if (fromSession != null && fromSession.isOpen()) {
            Map<String, Object> acceptMessage = Map.of(
                "type", "call_accepted",
                "callId", callId,
                "userId", userId,
                "timestamp", System.currentTimeMillis()
            );
            
            String acceptMsg = objectMapper.writeValueAsString(acceptMessage);
            fromSession.sendMessage(new TextMessage(acceptMsg));
        }
        
        log.info("通话已接受: {}", callId);
    }
    
    /**
     * 拒绝通话
     */
    public void rejectCall(String callId, String userId) throws IOException {
        CallSession callSession = activeCalls.get(callId);
        if (callSession == null) {
            return;
        }
        
        if (!callSession.getToUserId().equals(userId)) {
            return;
        }
        
        callSession.setStatus("rejected");
        
        // 通知发起方通话被拒绝
        WebSocketSession fromSession = userSessions.get(callSession.getFromUserId());
        if (fromSession != null && fromSession.isOpen()) {
            Map<String, Object> rejectMessage = Map.of(
                "type", "call_rejected",
                "callId", callId,
                "userId", userId,
                "timestamp", System.currentTimeMillis()
            );
            
            String rejectMsg = objectMapper.writeValueAsString(rejectMessage);
            fromSession.sendMessage(new TextMessage(rejectMsg));
        }
        
        activeCalls.remove(callId);
        log.info("通话被拒绝: {}", callId);
    }
    
    /**
     * 处理WebRTC信令
     */
    public void handleSignaling(String callId, String userId, String signalType, 
                               Object signalData) throws IOException {
        CallSession callSession = activeCalls.get(callId);
        if (callSession == null) {
            return;
        }
        
        // 确定目标用户
        String targetUserId = callSession.getFromUserId().equals(userId) ? 
                            callSession.getToUserId() : callSession.getFromUserId();
        
        WebSocketSession targetSession = userSessions.get(targetUserId);
        if (targetSession != null && targetSession.isOpen()) {
            Map<String, Object> signalingMessage = Map.of(
                "type", "signaling",
                "callId", callId,
                "fromUserId", userId,
                "signalType", signalType,
                "signalData", signalData,
                "timestamp", System.currentTimeMillis()
            );
            
            String signalingMsg = objectMapper.writeValueAsString(signalingMessage);
            targetSession.sendMessage(new TextMessage(signalingMsg));
            log.debug("信令消息已转发: {} -> {}", userId, targetUserId);
        }
    }
    
    /**
     * 结束通话
     */
    public void endCall(String callId, String userId) throws IOException {
        CallSession callSession = activeCalls.get(callId);
        if (callSession == null) {
            return;
        }
        
        callSession.setStatus("ended");
        callSession.setEndTime(System.currentTimeMillis());
        
        // 通知另一方通话结束
        String otherUserId = callSession.getFromUserId().equals(userId) ? 
                           callSession.getToUserId() : callSession.getFromUserId();
        
        WebSocketSession otherSession = userSessions.get(otherUserId);
        if (otherSession != null && otherSession.isOpen()) {
            Map<String, Object> endMessage = Map.of(
                "type", "call_ended",
                "callId", callId,
                "endedBy", userId,
                "duration", callSession.getEndTime() - callSession.getStartTime(),
                "timestamp", System.currentTimeMillis()
            );
            
            String endMsg = objectMapper.writeValueAsString(endMessage);
            otherSession.sendMessage(new TextMessage(endMsg));
        }
        
        activeCalls.remove(callId);
        log.info("通话已结束: {}", callId);
    }
    
    /**
     * 发送通话结束消息
     */
    private void sendCallEndMessage(String userId, String callId, String reason) throws IOException {
        WebSocketSession session = userSessions.get(userId);
        if (session != null && session.isOpen()) {
            Map<String, Object> message = Map.of(
                "type", "call_end",
                "callId", callId,
                "reason", reason,
                "timestamp", System.currentTimeMillis()
            );
            
            String endCallMsg = objectMapper.writeValueAsString(message);
            session.sendMessage(new TextMessage(endCallMsg));
        }
    }
    
    /**
     * 生成通话ID
     */
    private String generateCallId(String fromUserId, String toUserId) {
        return "call_" + fromUserId + "_" + toUserId + "_" + System.currentTimeMillis();
    }
    
    /**
     * 注册用户会话
     */
    public void registerUserSession(String userId, WebSocketSession session) {
        userSessions.put(userId, session);
        log.debug("用户会话已注册: {}", userId);
    }
    
    /**
     * 注销用户会话
     */
    public void unregisterUserSession(String userId) {
        userSessions.remove(userId);
        
        // 结束该用户的所有通话
        activeCalls.entrySet().removeIf(entry -> {
            CallSession session = entry.getValue();
            if (session.getFromUserId().equals(userId) || session.getToUserId().equals(userId)) {
                try {
                    endCall(session.getCallId(), userId);
                } catch (IOException e) {
                    log.error("结束通话失败", e);
                }
                return true;
            }
            return false;
        });
        
        log.debug("用户会话已注销: {}", userId);
    }
    
    /**
     * 获取活跃通话数量
     */
    public int getActiveCallCount() {
        return activeCalls.size();
    }
    
    /**
     * 获取在线用户数量
     */
    public int getOnlineUserCount() {
        return userSessions.size();
    }
    
    /**
     * 通话会话实体
     */
    @lombok.Data
    @lombok.Builder
    public static class CallSession {
        private String callId;
        private String fromUserId;
        private String toUserId;
        private boolean isVideoCall;
        private String status; // calling, accepted, rejected, ended
        private long startTime;
        private long endTime;
    }
}