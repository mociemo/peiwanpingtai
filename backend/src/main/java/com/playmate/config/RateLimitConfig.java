package com.playmate.config;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * API限流配置
 * 简化版实现，使用内存缓存进行限流
 */
@Configuration
@EnableCaching
public class RateLimitConfig {

    // 使用内存存储限流计数器
    private final ConcurrentHashMap<String, RateLimitInfo> rateLimitMap = new ConcurrentHashMap<>();
    
    /**
     * 限流信息类
     */
    public static class RateLimitInfo {
        private final AtomicInteger count;
        private final long windowStart;
        private final int maxRequests;
        private final long windowSizeMs;
        
        public RateLimitInfo(int maxRequests, long windowSizeMs) {
            this.count = new AtomicInteger(0);
            this.windowStart = System.currentTimeMillis();
            this.maxRequests = maxRequests;
            this.windowSizeMs = windowSizeMs;
        }
        
        public boolean tryConsume() {
            long now = System.currentTimeMillis();
            if (now - windowStart > windowSizeMs) {
                // 时间窗口已过，重置计数器
                count.set(0);
                return true;
            }
            return count.incrementAndGet() <= maxRequests;
        }
        
        public int getRemainingRequests() {
            return Math.max(0, maxRequests - count.get());
        }
    }
    
    /**
     * 检查是否允许请求
     */
    public boolean isAllowed(String key, int maxRequests, long windowSizeMs) {
        RateLimitInfo info = rateLimitMap.computeIfAbsent(key, 
            k -> new RateLimitInfo(maxRequests, windowSizeMs));
        return info.tryConsume();
    }
    
    /**
     * 获取剩余请求次数
     */
    public int getRemainingRequests(String key) {
        RateLimitInfo info = rateLimitMap.get(key);
        return info != null ? info.getRemainingRequests() : 0;
    }
    
    /**
     * 清理过期的限流记录
     */
    public void cleanup() {
        long now = System.currentTimeMillis();
        rateLimitMap.entrySet().removeIf(entry -> 
            now - entry.getValue().windowStart > 300000); // 5分钟过期
    }
}