package com.playmate.service;

import cn.jpush.api.JPushClient;
import cn.jpush.api.push.model.PushPayload;
import cn.jpush.api.push.model.Platform;
import cn.jpush.api.push.model.audience.Audience;
import cn.jpush.api.push.model.notification.AndroidNotification;
import cn.jpush.api.push.model.notification.IosNotification;
import cn.jpush.api.push.model.notification.Notification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * 推送通知服务
 * 使用极光推送进行离线消息推送
 */
@Slf4j
@Service
public class PushNotificationService {
    
    @Value("${jpush.appKey:}")
    private String appKey;
    
    @Value("${jpush.masterSecret:}")
    private String masterSecret;
    
    @Value("${jpush.apnsProduction:false}")
    private boolean apnsProduction;
    
    private JPushClient jPushClient;
    
    /**
     * 初始化推送客户端
     */
    private JPushClient getJPushClient() {
        if (jPushClient == null && isConfigured()) {
            jPushClient = new JPushClient(masterSecret, appKey);
        }
        return jPushClient;
    }
    
    /**
     * 推送给单个用户
     */
    public boolean pushToUser(String userId, String title, String content, Map<String, String> extras) {
        if (!isConfigured()) {
            log.warn("极光推送未配置，跳过推送");
            return false;
        }
        
        try {
            PushPayload payload = PushPayload.newBuilder()
                    .setPlatform(Platform.all())
                    .setAudience(Audience.alias(userId))
                    .setNotification(Notification.newBuilder()
                            .setAlert(content)
                            .addPlatformNotification(AndroidNotification.newBuilder()
                                    .setTitle(title)
                                    .addExtras(extras)
                                    .build())
                            .addPlatformNotification(IosNotification.newBuilder()
                                    .setAlert(content)
                                    .addExtras(extras)
                                    .setBadge(1)
                                    .setSound("default")
                                    .build())
                            .build())
                    .build();
            
            getJPushClient().sendPush(payload);
            log.info("推送成功: userId={}, title={}", userId, title);
            return true;
            
        } catch (Exception e) {
            log.error("推送失败: userId={}", userId, e);
            return false;
        }
    }
    
    /**
     * 推送给多个用户
     */
    public boolean pushToUsers(String[] userIds, String title, String content, Map<String, String> extras) {
        if (!isConfigured()) {
            log.warn("极光推送未配置，跳过推送");
            return false;
        }
        
        try {
            PushPayload payload = PushPayload.newBuilder()
                    .setPlatform(Platform.all())
                    .setAudience(Audience.alias(userIds))
                    .setNotification(Notification.newBuilder()
                            .setAlert(content)
                            .addPlatformNotification(AndroidNotification.newBuilder()
                                    .setTitle(title)
                                    .addExtras(extras)
                                    .build())
                            .addPlatformNotification(IosNotification.newBuilder()
                                    .setAlert(content)
                                    .addExtras(extras)
                                    .setBadge(1)
                                    .setSound("default")
                                    .build())
                            .build())
                    .build();
            
            getJPushClient().sendPush(payload);
            log.info("群推送成功: userCount={}, title={}", userIds.length, title);
            return true;
            
        } catch (Exception e) {
            log.error("群推送失败", e);
            return false;
        }
    }
    
    /**
     * 推送给所有用户
     */
    public boolean pushToAll(String title, String content, Map<String, String> extras) {
        if (!isConfigured()) {
            log.warn("极光推送未配置，跳过推送");
            return false;
        }
        
        try {
            PushPayload payload = PushPayload.newBuilder()
                    .setPlatform(Platform.all())
                    .setAudience(Audience.all())
                    .setNotification(Notification.newBuilder()
                            .setAlert(content)
                            .addPlatformNotification(AndroidNotification.newBuilder()
                                    .setTitle(title)
                                    .addExtras(extras)
                                    .build())
                            .addPlatformNotification(IosNotification.newBuilder()
                                    .setAlert(content)
                                    .addExtras(extras)
                                    .setBadge(1)
                                    .setSound("default")
                                    .build())
                            .build())
                    .build();
            
            getJPushClient().sendPush(payload);
            log.info("全量推送成功: title={}", title);
            return true;
            
        } catch (Exception e) {
            log.error("全量推送失败", e);
            return false;
        }
    }
    
    /**
     * 推送新消息通知
     */
    public boolean pushNewMessage(String toUserId, String fromUserName, String messageContent) {
        Map<String, String> extras = Map.of(
            "type", "new_message",
            "fromUserId", fromUserName,
            "message", messageContent
        );
        
        return pushToUser(
            toUserId,
            "新消息",
            fromUserName + ": " + messageContent,
            extras
        );
    }
    
    /**
     * 推送订单状态变更通知
     */
    public boolean pushOrderStatusChange(String userId, String orderNo, String status) {
        Map<String, String> extras = Map.of(
            "type", "order_status",
            "orderNo", orderNo,
            "status", status
        );
        
        return pushToUser(
            userId,
            "订单状态更新",
            "订单 " + orderNo + " 状态已更新为: " + status,
            extras
        );
    }
    
    /**
     * 推送通话邀请
     */
    public boolean pushCallInvite(String toUserId, String fromUserName, boolean isVideoCall) {
        String callType = isVideoCall ? "视频" : "语音";
        Map<String, String> extras = Map.of(
            "type", "call_invite",
            "fromUserId", fromUserName,
            "isVideoCall", String.valueOf(isVideoCall)
        );
        
        return pushToUser(
            toUserId,
            "通话邀请",
            fromUserName + " 邀请您进行" + callType + "通话",
            extras
        );
    }
    
    /**
     * 推送系统通知
     */
    public boolean pushSystemNotification(String title, String content) {
        Map<String, String> extras = Map.of(
            "type", "system_notification"
        );
        
        return pushToAll(title, content, extras);
    }
    
    /**
     * 设置用户别名
     */
    public boolean setUserAlias(String userId, String alias) {
        if (!isConfigured()) {
            return false;
        }
        
        try {
            // 这里需要调用极光推送的API设置别名
            // 具体实现需要参考极光推送文档
            log.info("设置用户别名: userId={}, alias={}", userId, alias);
            return true;
            
        } catch (Exception e) {
            log.error("设置用户别名失败: userId={}", userId, e);
            return false;
        }
    }
    
    /**
     * 删除用户别名
     */
    public boolean deleteUserAlias(String userId) {
        if (!isConfigured()) {
            return false;
        }
        
        try {
            // 这里需要调用极光推送的API删除别名
            log.info("删除用户别名: userId={}", userId);
            return true;
            
        } catch (Exception e) {
            log.error("删除用户别名失败: userId={}", userId, e);
            return false;
        }
    }
    
    /**
     * 检查是否已配置
     */
    private boolean isConfigured() {
        return appKey != null && !appKey.isEmpty() &&
               masterSecret != null && !masterSecret.isEmpty();
    }
    
    /**
     * 获取推送统计信息
     */
    public Map<String, Object> getPushStats() {
        return Map.of(
            "configured", isConfigured(),
            "apnsProduction", apnsProduction
        );
    }
}