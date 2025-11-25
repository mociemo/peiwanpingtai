package com.playmate.interceptor;

import com.playmate.config.RateLimitConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * API限流拦截器
 * 实现接口访问频率限制
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RateLimitInterceptor implements HandlerInterceptor {

    private final RateLimitConfig rateLimitConfig;

    @Override
    public boolean preHandle(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull Object handler) throws IOException {
        String clientIp = getClientIp(request);
        String requestUri = request.getRequestURI();
        String key = clientIp + ":" + requestUri;
        
        // 根据不同的API端点设置不同的限流规则
        boolean allowed = checkRateLimit(key, requestUri);
        
        if (allowed) {
            return true;
        }
        
        // 限流处理
        log.warn("API限流触发 - IP: {}, URI: {}", clientIp, requestUri);
        
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(429); // Too Many Requests
        
        String jsonResponse = "{\"code\":429,\"message\":\"请求过于频繁，请稍后再试\",\"data\":null}";
        response.getWriter().write(jsonResponse);
        
        return false;
    }

    /**
     * 检查限流规则
     */
    private boolean checkRateLimit(String key, String requestUri) {
        if (requestUri.contains("/payment/") || requestUri.contains("/order/")) {
            // 支付API：每分钟20次
            return rateLimitConfig.isAllowed(key, 20, 60000);
        } else if (requestUri.contains("/auth/login")) {
            // 登录API：每分钟10次
            return rateLimitConfig.isAllowed(key, 10, 60000);
        } else if (requestUri.contains("/auth/register")) {
            // 注册API：每小时5次
            return rateLimitConfig.isAllowed(key, 5, 3600000);
        } else if (requestUri.contains("/upload")) {
            // 上传API：每分钟10次
            return rateLimitConfig.isAllowed(key, 10, 60000);
        } else {
            // 普通API：每分钟100次
            return rateLimitConfig.isAllowed(key, 100, 60000);
        }
    }

    /**
     * 获取客户端真实IP
     */
    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty() && !"unknown".equalsIgnoreCase(xRealIp)) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
}