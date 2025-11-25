package com.playmate.config;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 缓存配置
 * 为高频查询添加缓存支持，提升系统性能
 */
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        ConcurrentMapCacheManager cacheManager = new ConcurrentMapCacheManager();
        // 配置缓存区域
        cacheManager.setCacheNames(java.util.List.of(
            "users",           // 用户信息缓存
            "players",         // 陪玩达人信息缓存
            "wallets",         // 钱包信息缓存（短期缓存）
            "popularPlayers",  // 热门陪玩达人缓存
            "gameTypes"        // 游戏类型缓存
        ));
        
        // 缓存配置
        cacheManager.setAllowNullValues(false); // 不允许缓存null值
        
        return cacheManager;
    }
}