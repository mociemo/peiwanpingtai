package com.playmate.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 告警服务
 * 发送各种类型的告警通知
 */
@Slf4j
@Service
@RequiredArgsConstructor
@SuppressWarnings("null")
public class AlertService {

    private final JavaMailSender mailSender;
    private final RestTemplate restTemplate;

    @Value("${app.alert.email.enabled:false}")
    private boolean emailAlertEnabled;

    @Value("${app.alert.email.recipients:admin@playmate.com}")
    private String emailRecipientsStr;

    @Value("${app.alert.webhook.enabled:false}")
    private boolean webhookAlertEnabled;

    @Value("${app.alert.webhook.url:}")
    private String webhookUrl;

    /**
     * 发送安全告警
     */
    @Async("taskExecutor")
    public void sendSecurityAlert(String alertType, String message) {
        log.warn("安全告警 [{}]: {}", alertType, message);
        
        if (emailAlertEnabled) {
            sendEmailAlert("【安全告警】" + alertType, message);
        }
        
        if (webhookAlertEnabled) {
            sendWebhookAlert("SECURITY", alertType, message);
        }
    }

    /**
     * 发送业务告警
     */
    @Async("taskExecutor")
    public void sendBusinessAlert(String alertType, String message) {
        log.warn("业务告警 [{}]: {}", alertType, message);
        
        if (emailAlertEnabled) {
            sendEmailAlert("【业务告警】" + alertType, message);
        }
        
        if (webhookAlertEnabled) {
            sendWebhookAlert("BUSINESS", alertType, message);
        }
    }

    /**
     * 发送系统告警
     */
    @Async("taskExecutor")
    public void sendSystemAlert(String alertType, String message) {
        log.error("系统告警 [{}]: {}", alertType, message);
        
        if (emailAlertEnabled) {
            sendEmailAlert("【系统告警】" + alertType, message);
        }
        
        if (webhookAlertEnabled) {
            sendWebhookAlert("SYSTEM", alertType, message);
        }
    }

    /**
     * 发送性能告警
     */
    @Async("taskExecutor")
    public void sendPerformanceAlert(String alertType, String message) {
        log.warn("性能告警 [{}]: {}", alertType, message);
        
        if (emailAlertEnabled) {
            sendEmailAlert("【性能告警】" + alertType, message);
        }
        
        if (webhookAlertEnabled) {
            sendWebhookAlert("PERFORMANCE", alertType, message);
        }
    }

    /**
     * 发送邮件告警
     */
    private void sendEmailAlert(String subject, String message) {
        try {
            String recipientsStr = emailRecipientsStr != null ? emailRecipientsStr : "admin@playmate.com";
            String[] recipients = recipientsStr.split(",");
            if (recipients == null || recipients.length == 0) {
                recipients = new String[]{"admin@playmate.com"};
            }
            SimpleMailMessage mailMessage = new SimpleMailMessage();
            mailMessage.setTo(recipients);
            mailMessage.setSubject(subject);
            mailMessage.setText(String.format(
                "告警时间: %s\n\n告警内容:\n%s\n\n请及时处理！",
                LocalDateTime.now().toString(),
                message
            ));
            
            mailSender.send(mailMessage);
            log.info("邮件告警发送成功: {}", subject);
        } catch (Exception e) {
            log.error("发送邮件告警失败", e);
        }
    }

    /**
     * 发送Webhook告警
     */
    private void sendWebhookAlert(String category, String alertType, String message) {
        try {
            if (webhookUrl == null || webhookUrl.trim().isEmpty()) {
                log.warn("Webhook URL未配置，跳过Webhook告警");
                return;
            }
            
            // 构建告警JSON
            String jsonPayload = String.format(
                "{\"category\":\"%s\",\"alertType\":\"%s\",\"message\":\"%s\",\"timestamp\":\"%s\",\"service\":\"playmate-backend\"}",
                category, alertType, message, LocalDateTime.now().toString()
            );
            
            log.debug("Webhook告警内容: {}", jsonPayload);
            
            // 发送HTTP请求到Webhook
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("User-Agent", "PlayMate-Alert/1.0");
            
            HttpEntity<String> entity = new HttpEntity<>(jsonPayload, headers);
            
            // 发送请求，设置超时时间
            @SuppressWarnings("null")
            String url = webhookUrl;
            restTemplate.postForEntity(url, entity, String.class);
            
            log.info("Webhook告警发送成功: {} - {} -> {}", category, alertType, webhookUrl);
            
        } catch (Exception e) {
            log.error("发送Webhook告警失败: {}", e.getMessage(), e);
        }
    }

    /**
     * 发送系统报告
     */
    @Async("taskExecutor")
    public void sendSystemReport(java.util.Map<String, Object> report) {
        if (!emailAlertEnabled) {
            return;
        }
        
        try {
            StringBuilder reportText = new StringBuilder();
            reportText.append("系统运行报告\n");
            reportText.append("报告时间: ").append(LocalDateTime.now().toString()).append("\n\n");
            
            for (Map.Entry<String, Object> entry : report.entrySet()) {
                reportText.append(entry.getKey()).append(": ").append(entry.getValue()).append("\n");
            }
            
            String recipientsStr = emailRecipientsStr != null ? emailRecipientsStr : "admin@playmate.com";
            String[] recipients = recipientsStr.split(",");
            if (recipients == null || recipients.length == 0) {
                recipients = new String[]{"admin@playmate.com"};
            }
            SimpleMailMessage mailMessage = new SimpleMailMessage();
            mailMessage.setTo(recipients);
            mailMessage.setSubject("【系统报告】PlayMate运行状态");
            mailMessage.setText(reportText.toString());
            
            mailSender.send(mailMessage);
            log.info("系统报告发送成功");
        } catch (Exception e) {
            log.error("发送系统报告失败", e);
        }
    }

    /**
     * 测试告警功能
     */
    public void testAlerts() {
        sendSecurityAlert("TEST", "这是一个测试安全告警");
        sendBusinessAlert("TEST", "这是一个测试业务告警");
        sendSystemAlert("TEST", "这是一个测试系统告警");
        sendPerformanceAlert("TEST", "这是一个测试性能告警");
    }
}