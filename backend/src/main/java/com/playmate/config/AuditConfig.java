package com.playmate.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.lang.NonNull;

import java.util.Optional;

/**
 * 审计配置
 * 启用JPA审计功能，自动记录创建时间、修改时间等
 */
@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class AuditConfig {

    @Bean
    public AuditorAware<String> auditorProvider() {
        return new AuditorAwareImpl();
    }

    /**
     * 审计提供者实现
     */
    @SuppressWarnings("null")
    public static class AuditorAwareImpl implements AuditorAware<String> {
        
        @Override
        @NonNull
        public Optional<String> getCurrentAuditor() {
            // 从SecurityContext获取当前用户
            try {
                org.springframework.security.core.context.SecurityContext context = 
                    org.springframework.security.core.context.SecurityContextHolder.getContext();
                
                if (context != null && context.getAuthentication() != null) {
                    String username = context.getAuthentication().getName();
                    if (username != null && !username.trim().isEmpty()) {
                        return Optional.of(username);
                    }
                }
            } catch (Exception e) {
                // 忽略异常，返回系统用户
            }
            
            return Optional.of("system");
        }
    }
}