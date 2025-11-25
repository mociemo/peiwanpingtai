package com.playmate.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 监控配置
 * 配置应用监控指标
 */
@Configuration
@EnableScheduling
public class MonitoringConfig {
    
    // 简化版监控配置，不依赖外部监控库
    // 可以通过Spring Boot Actuator基础功能进行监控
}