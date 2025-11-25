package com.playmate.service;

import com.playmate.entity.AuditLog;
import com.playmate.repository.AuditLogRepository;
import com.playmate.util.EncryptionUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 审计日志服务
 * 记录系统操作日志
 */
@Slf4j
@Service
@RequiredArgsConstructor
@SuppressWarnings("null")
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final EncryptionUtils encryptionUtils;

    /**
     * 记录登录日志
     */
    @Async("taskExecutor")
    public void logLogin(String username, String ip, boolean success, String failureReason) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .username(username)
                    .operation("LOGIN")
                    .ipAddress(ip)
                    .success(success)
                    .failureReason(failureReason)
                    .createTime(LocalDateTime.now())
                    .build();

            auditLogRepository.save(auditLog);
            
            if (success) {
                log.info("用户登录成功: {}, IP: {}", username, ip);
            } else {
                log.warn("用户登录失败: {}, IP: {}, 原因: {}", username, ip, failureReason);
            }
        } catch (Exception e) {
            log.error("记录登录日志失败", e);
        }
    }

    /**
     * 记录操作日志
     */
    @Async("taskExecutor")
    public void logOperation(String username, String operation, String resource, String details, 
                         HttpServletRequest request) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .username(username)
                    .operation(operation)
                    .resource(resource)
                    .details(details)
                    .ipAddress(getClientIp(request))
                    .userAgent(request.getHeader("User-Agent"))
                    .requestUri(request.getRequestURI())
                    .httpMethod(request.getMethod())
                    .success(true)
                    .createTime(LocalDateTime.now())
                    .build();

            auditLogRepository.save(auditLog);
            log.info("操作日志: {} {} {}", username, operation, resource);
        } catch (Exception e) {
            log.error("记录操作日志失败", e);
        }
    }

    /**
     * 记录支付日志
     */
    @Async("taskExecutor")
    public void logPayment(String username, String operation, String paymentNo, 
                        BigDecimal amount, boolean success, String details) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .username(username)
                    .operation("PAYMENT_" + operation)
                    .resource(paymentNo)
                    .details(details)
                    .amount(amount)
                    .success(success)
                    .createTime(LocalDateTime.now())
                    .build();

            auditLogRepository.save(auditLog);
            
            if (success) {
                log.info("支付日志: {} {} {}", username, operation, paymentNo);
            } else {
                log.warn("支付失败: {} {} {}", username, operation, paymentNo);
            }
        } catch (Exception e) {
            log.error("记录支付日志失败", e);
        }
    }

    /**
     * 记录安全事件
     */
    @Async("taskExecutor")
    public void logSecurityEvent(String username, String eventType, String details, 
                             HttpServletRequest request) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .username(username)
                    .operation("SECURITY_" + eventType)
                    .details(details)
                    .ipAddress(getClientIp(request))
                    .userAgent(request.getHeader("User-Agent"))
                    .requestUri(request.getRequestURI())
                    .httpMethod(request.getMethod())
                    .success(false) // 安全事件通常标记为失败
                    .createTime(LocalDateTime.now())
                    .build();

            auditLogRepository.save(auditLog);
            log.warn("安全事件: {} {} {}", username, eventType, details);
        } catch (Exception e) {
            log.error("记录安全事件失败", e);
        }
    }

    /**
     * 记录数据修改日志
     */
    @Async("taskExecutor")
    public void logDataModification(String username, String operation, String resourceType, 
                               String resourceId, String oldValue, String newValue) {
        try {
            // 敏感数据脱敏
            String maskedOldValue = maskSensitiveData(oldValue);
            String maskedNewValue = maskSensitiveData(newValue);

            AuditLog auditLog = AuditLog.builder()
                    .username(username)
                    .operation(operation)
                    .resourceType(resourceType)
                    .resourceId(resourceId)
                    .details(String.format("旧值: %s -> 新值: %s", maskedOldValue, maskedNewValue))
                    .success(true)
                    .createTime(LocalDateTime.now())
                    .build();

            auditLogRepository.save(auditLog);
            log.info("数据修改日志: {} {} {} {}", username, operation, resourceType, resourceId);
        } catch (Exception e) {
            log.error("记录数据修改日志失败", e);
        }
    }

    /**
     * 查询审计日志
     */
    public Page<AuditLog> queryAuditLogs(String username, String operation, 
                                       LocalDateTime startTime, LocalDateTime endTime, 
                                       Pageable pageable) {
        return auditLogRepository.findByConditions(username, operation, startTime, endTime, pageable);
    }

    /**
     * 查询用户操作历史
     */
    public List<AuditLog> getUserOperationHistory(String username, int limit) {
        return auditLogRepository.findByUsernameOrderByCreateTimeDesc(
            username, org.springframework.data.domain.PageRequest.of(0, limit)).getContent();
    }

    /**
     * 查询安全事件
     */
    public Page<AuditLog> getSecurityEvents(LocalDateTime startTime, LocalDateTime endTime, 
                                         Pageable pageable) {
        return auditLogRepository.findByOperationStartingWithAndCreateTimeBetween(
                "SECURITY_", startTime, endTime, pageable);
    }

    /**
     * 获取客户端IP
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

    /**
     * 敏感数据脱敏
     */
    private String maskSensitiveData(String data) {
        if (data == null) {
            return null;
        }
        
        // 手机号脱敏
        if (data.matches("^1[3-9]\\d{9}$")) {
            return encryptionUtils.maskPhone(data);
        }
        
        // 邮箱脱敏
        if (data.contains("@")) {
            return encryptionUtils.maskEmail(data);
        }
        
        // 身份证脱敏
        if (data.matches("^\\d{15}|\\d{18}$")) {
            return encryptionUtils.maskIdCard(data);
        }
        
        // 银行卡脱敏
        if (data.matches("^\\d{16,19}$")) {
            return encryptionUtils.maskBankCard(data);
        }
        
        // 其他敏感数据部分脱敏
        if (data.length() > 8) {
            return data.substring(0, 3) + "***" + data.substring(data.length() - 3);
        }
        
        return data;
    }
}