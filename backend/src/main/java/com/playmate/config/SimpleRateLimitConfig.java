package com.playmate.config;

import org.springframework.context.annotation.Configuration;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 简单的API限流配置
 * 使用内存计数器实现限流功能
 */
@Configuration
public class SimpleRateLimitConfig {

    private final ConcurrentHashMap<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Long> lastResetTime = new ConcurrentHashMap<>();

    // 默认限流配置
    private int apiLimit = 100; // 每分钟100次
    private int paymentLimit = 20; // 每分钟20次
    private int loginLimit = 10; // 每分钟10次
    private int registerLimit = 5; // 每小时5次
    private int uploadLimit = 10; // 每分钟10次

    /**
     * 检查是否允许请求
     */
    public boolean isAllowed(String key, int limit, long windowMillis) {
        long currentTime = System.currentTimeMillis();
        Long lastReset = lastResetTime.get(key);
        
        if (lastReset == null || currentTime - lastReset > windowMillis) {
            requestCounts.put(key, new AtomicInteger(0));
            lastResetTime.put(key, currentTime);
        }
        
        AtomicInteger count = requestCounts.get(key);
        if (count == null) {
            count = new AtomicInteger(0);
            requestCounts.put(key, count);
        }
        
        return count.incrementAndGet() <= limit;
    }

    /**
     * 获取API限流检查器
     */
    public boolean checkApiLimit(String clientIp) {
        return isAllowed("api_" + clientIp, apiLimit, 60000); // 1分钟
    }

    /**
     * 获取支付限流检查器
     */
    public boolean checkPaymentLimit(String clientIp) {
        return isAllowed("payment_" + clientIp, paymentLimit, 60000); // 1分钟
    }

    /**
     * 获取登录限流检查器
     */
    public boolean checkLoginLimit(String clientIp) {
        return isAllowed("login_" + clientIp, loginLimit, 60000); // 1分钟
    }

    /**
     * 获取注册限流检查器
     */
    public boolean checkRegisterLimit(String clientIp) {
        return isAllowed("register_" + clientIp, registerLimit, 3600000); // 1小时
    }

    /**
     * 获取上传限流检查器
     */
    public boolean checkUploadLimit(String clientIp) {
        return isAllowed("upload_" + clientIp, uploadLimit, 60000); // 1分钟
    }

    // Getters and Setters
    public int getApiLimit() { return apiLimit; }
    public void setApiLimit(int apiLimit) { this.apiLimit = apiLimit; }

    public int getPaymentLimit() { return paymentLimit; }
    public void setPaymentLimit(int paymentLimit) { this.paymentLimit = paymentLimit; }

    public int getLoginLimit() { return loginLimit; }
    public void setLoginLimit(int loginLimit) { this.loginLimit = loginLimit; }

    public int getRegisterLimit() { return registerLimit; }
    public void setRegisterLimit(int registerLimit) { this.registerLimit = registerLimit; }

    public int getUploadLimit() { return uploadLimit; }
    public void setUploadLimit(int uploadLimit) { this.uploadLimit = uploadLimit; }
}