package com.playmate.service;

import com.playmate.repository.AuditLogRepository;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 监控服务
 * 实时监控系统状态并发送告警
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MonitoringService {

    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;
    private final AlertService alertService;

    /**
     * 每5分钟检查一次系统状态
     */
    @Scheduled(fixedRate = 300000) // 5分钟
    public void checkSystemHealth() {
        try {
            checkFailedLoginRate();
            checkPaymentFailureRate();
            checkSystemErrorRate();
            checkDatabaseConnection();
        } catch (Exception e) {
            log.error("系统健康检查失败", e);
        }
    }

    /**
     * 每小时生成系统报告
     */
    @Scheduled(fixedRate = 3600000) // 1小时
    public void generateHourlyReport() {
        try {
            Map<String, Object> report = generateSystemReport();
            log.info("系统报告: {}", report);
            
            // 发送报告（如果需要）
            // alertService.sendSystemReport(report);
        } catch (Exception e) {
            log.error("生成系统报告失败", e);
        }
    }

    /**
     * 每天清理过期数据
     */
    @Scheduled(cron = "0 0 2 * * ?") // 每天凌晨2点
    public void cleanupExpiredData() {
        try {
            // 清理30天前的审计日志
            LocalDateTime expireTime = LocalDateTime.now().minusDays(30);
            auditLogRepository.deleteExpiredLogs(expireTime);
            log.info("清理过期审计日志完成");
        } catch (Exception e) {
            log.error("清理过期数据失败", e);
        }
    }

    /**
     * 检查登录失败率
     */
    private void checkFailedLoginRate() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime fiveMinutesAgo = now.minusMinutes(5);

        long failedLoginCount = auditLogRepository.findByOperationAndCreateTimeBetween(
                "LOGIN", fiveMinutesAgo, now, 
                org.springframework.data.domain.PageRequest.of(0, 1000)).getContent().stream()
                .filter(log -> Boolean.FALSE.equals(log.getSuccess()))
                .count();

        // 如果5分钟内失败登录超过10次，触发告警
        if (failedLoginCount > 10) {
            String message = String.format("5分钟内登录失败次数: %d，可能存在暴力破解", failedLoginCount);
            alertService.sendSecurityAlert("HIGH_LOGIN_FAILURE_RATE", message);
        }
    }

    /**
     * 检查支付失败率
     */
    private void checkPaymentFailureRate() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime oneHourAgo = now.minusHours(1);

        var paymentLogs = auditLogRepository.findByOperationStartingWithAndCreateTimeBetween(
                "PAYMENT_", oneHourAgo, now, null);
        long totalPayments = paymentLogs.getContent().size();
        long failedPayments = paymentLogs.getContent().stream()
                .mapToLong(log -> Boolean.TRUE.equals(log.getSuccess()) ? 0 : 1)
                .sum();

        if (totalPayments > 0) {
            double failureRate = (double) failedPayments / totalPayments;
            
            // 如果支付失败率超过20%，触发告警
            if (failureRate > 0.2) {
                String message = String.format("1小时内支付失败率: %.2f%% (%d/%d)", 
                        failureRate * 100, failedPayments, totalPayments);
                alertService.sendBusinessAlert("HIGH_PAYMENT_FAILURE_RATE", message);
            }
        }
    }

    /**
     * 检查系统错误率
     */
    private void checkSystemErrorRate() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime fiveMinutesAgo = now.minusMinutes(5);

        var errorLogs = auditLogRepository.findByOperationStartingWithAndCreateTimeBetween(
                "ERROR_", fiveMinutesAgo, now, null);
        long errorCount = errorLogs.getContent().size();

        // 如果5分钟内错误超过5次，触发告警
        if (errorCount > 5) {
            String message = String.format("5分钟内系统错误次数: %d", errorCount);
            alertService.sendSystemAlert("HIGH_ERROR_RATE", message);
        }
    }

    /**
     * 检查数据库连接
     */
    private void checkDatabaseConnection() {
        try {
            userRepository.count(); // 简单的数据库连接测试
        } catch (Exception e) {
            String message = "数据库连接异常: " + e.getMessage();
            alertService.sendSystemAlert("DATABASE_CONNECTION_ERROR", message);
        }
    }

    /**
     * 生成系统报告
     */
    private Map<String, Object> generateSystemReport() {
        Map<String, Object> report = new HashMap<>();
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime oneHourAgo = now.minusHours(1);
        
        // 用户统计
        long totalUsers = userRepository.count();
        report.put("totalUsers", totalUsers);
        
        // 支付统计
        var paymentLogs = auditLogRepository.findByOperationStartingWithAndCreateTimeBetween(
                "PAYMENT_", oneHourAgo, now, null);
        long totalPayments = paymentLogs.getContent().size();
        long successfulPayments = paymentLogs.getContent().stream()
                .mapToLong(log -> Boolean.TRUE.equals(log.getSuccess()) ? 1 : 0)
                .sum();
        report.put("totalPayments", totalPayments);
        report.put("successfulPayments", successfulPayments);
        
        // 错误统计
        var errorLogs = auditLogRepository.findByOperationStartingWithAndCreateTimeBetween(
                "ERROR_", oneHourAgo, now, null);
        report.put("errorCount", errorLogs.getContent().size());
        
        // 活跃用户统计
        var activeUsers = auditLogRepository.findByCreateTimeBetween(oneHourAgo, now, 
            org.springframework.data.domain.PageRequest.of(0, 1000));
        report.put("activeUsers", activeUsers.getContent().size());
        
        return report;
    }
}