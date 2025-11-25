package com.playmate.handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.playmate.service.WebRTCService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;

/**
 * WebRTC信令处理器
 */
@Slf4j
@Component
@RequiredArgsConstructor
@SuppressWarnings("null")
public class WebRTCHandler extends TextWebSocketHandler {

    private final WebRTCService webRTCService;
    private final ObjectMapper objectMapper;

    @Override
    public void afterConnectionEstablished(@NonNull WebSocketSession session) throws Exception {
        log.info("WebSocket连接建立: {}", session.getId());

        // 从查询参数中获取用户ID
        try {
            @SuppressWarnings("null")
            java.net.URI uri = session.getUri();
            if (uri != null) {
                String query = uri.getQuery();
                if (query != null && !query.isEmpty()) {
                    String[] params = query.split("&");
                    for (String param : params) {
                        if (param.startsWith("userId=")) {
                            String userId = param.substring(7);
                            webRTCService.registerUserSession(userId, session);
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.warn("获取WebSocket查询参数失败: {}", e.getMessage());
        }
    }

    @Override
    protected void handleTextMessage(@NonNull WebSocketSession session, @NonNull TextMessage message) throws Exception {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(message.getPayload(), Map.class);
            String type = (String) data.get("type");

            switch (type) {
                case "initiate_call":
                    handleInitiateCall(session, data);
                    break;
                case "accept_call":
                    handleAcceptCall(session, data);
                    break;
                case "reject_call":
                    handleRejectCall(session, data);
                    break;
                case "end_call":
                    handleEndCall(session, data);
                    break;
                case "signaling":
                    handleSignaling(session, data);
                    break;
                default:
                    log.warn("未知消息类型: {}", type);
            }
        } catch (Exception e) {
            log.error("处理WebSocket消息失败", e);
            sendErrorMessage(session, "消息处理失败: " + e.getMessage());
        }
    }

    @Override
    public void afterConnectionClosed(@NonNull WebSocketSession session, @NonNull CloseStatus status) throws Exception {
        log.info("WebSocket连接关闭: {}", session.getId());

        // 注销用户会话
        webRTCService.unregisterUserSession(session.getId());
    }

    private void handleInitiateCall(WebSocketSession session, Map<String, Object> data) throws Exception {
        String fromUserId = (String) data.get("fromUserId");
        String toUserId = (String) data.get("toUserId");
        Boolean isVideoCall = (Boolean) data.get("isVideoCall");

        webRTCService.initiateCall(fromUserId, toUserId, isVideoCall, session);
    }

    private void handleAcceptCall(WebSocketSession session, Map<String, Object> data) throws Exception {
        String callId = (String) data.get("callId");
        String userId = (String) data.get("userId");

        webRTCService.acceptCall(callId, userId, session);
    }

    private void handleRejectCall(WebSocketSession session, Map<String, Object> data) throws Exception {
        String callId = (String) data.get("callId");
        String userId = (String) data.get("userId");

        webRTCService.rejectCall(callId, userId);
    }

    private void handleEndCall(WebSocketSession session, Map<String, Object> data) throws Exception {
        String callId = (String) data.get("callId");
        String userId = (String) data.get("userId");

        webRTCService.endCall(callId, userId);
    }

    private void handleSignaling(WebSocketSession session, Map<String, Object> data) throws Exception {
        String callId = (String) data.get("callId");
        String userId = (String) data.get("userId");
        String signalType = (String) data.get("signalType");
        Object signalData = data.get("signalData");

        webRTCService.handleSignaling(callId, userId, signalType, signalData);
    }

    private void sendErrorMessage(WebSocketSession session, String message) throws Exception {
        Map<String, Object> errorResponse = Map.of(
                "type", "error",
                "message", message,
                "timestamp", System.currentTimeMillis());

        @SuppressWarnings("null")
        String jsonResponse = objectMapper.writeValueAsString(errorResponse);
        session.sendMessage(new TextMessage(jsonResponse));
    }
}