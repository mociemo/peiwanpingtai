package com.playmate.config;

import cn.jpush.api.JPushClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 推送通知配置
 */
@Slf4j
@Configuration
@ConditionalOnProperty(name = {"jpush.appKey", "jpush.masterSecret"})
public class PushNotificationConfig {
    
    @Value("${jpush.app-key}")
    private String appKey;
    
    @Value("${jpush.master-secret}")
    private String masterSecret;
    
    @Value("${jpush.apns-production:false}")
    private boolean apnsProduction;
    
    @Bean
    public JPushClient jPushClient() {
        log.info("初始化极光推送客户端: appKey={}, apnsProduction={}", appKey, apnsProduction);
        return new JPushClient(masterSecret, appKey);
    }
}