package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.User;
import com.playmate.service.UserService;
import com.playmate.service.SmsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/security")
@RequiredArgsConstructor
@Slf4j
public class SecurityController {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final SmsService smsService;

    /**
     * 修改密码
     */
    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<Map<String, Object>>> changePassword(
            Authentication authentication,
            @RequestBody Map<String, String> passwordData) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            
            String currentPassword = passwordData.get("currentPassword");
            String newPassword = passwordData.get("newPassword");
            
            // 验证当前密码
            if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
                return ResponseEntity.badRequest().body(ApiResponse.error("当前密码不正确"));
            }
            
            // 更新密码
            user.setPassword(passwordEncoder.encode(newPassword));
            userService.saveUser(user);
            
            Map<String, Object> result = new HashMap<>();
            result.put("message", "密码修改成功");
            result.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("修改密码失败: " + e.getMessage()));
        }
    }

    /**
     * 发送验证码
     */
    @PostMapping("/send-verification-code")
    public ResponseEntity<ApiResponse<Map<String, Object>>> sendVerificationCode(
            @RequestBody Map<String, String> requestData) {
        try {
            String phone = requestData.get("phone");
            
            if (phone == null || phone.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("手机号不能为空"));
            }
            
            // 检查手机号格式
            if (!phone.matches("^1[3-9]\\d{9}$")) {
                return ResponseEntity.badRequest().body(ApiResponse.error("手机号格式不正确"));
            }
            
            // 检查是否被阻止
            if (smsService.isBlocked(phone)) {
                return ResponseEntity.badRequest().body(ApiResponse.error("验证码发送过于频繁，请稍后再试"));
            }
            
            // 发送验证码
            boolean success = smsService.sendVerificationCode(phone);
            
            if (!success) {
                return ResponseEntity.badRequest().body(ApiResponse.error("验证码发送失败，请稍后重试"));
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("message", "验证码已发送");
            result.put("phone", phone);
            result.put("remainingAttempts", smsService.getRemainingAttempts(phone));
            result.put("timestamp", System.currentTimeMillis());
            
            log.info("验证码发送成功: {}", phone);
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("发送验证码失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("发送验证码失败: " + e.getMessage()));
        }
    }

    /**
     * 验证验证码并绑定手机
     */
    @PostMapping("/bind-phone")
    public ResponseEntity<ApiResponse<Map<String, Object>>> bindPhone(
            Authentication authentication,
            @RequestBody Map<String, String> requestData) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            
            String phone = requestData.get("phone");
            String code = requestData.get("code");
            
            if (phone == null || phone.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("手机号不能为空"));
            }
            
            if (code == null || code.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("验证码不能为空"));
            }
            
            // 检查手机号格式
            if (!phone.matches("^1[3-9]\\d{9}$")) {
                return ResponseEntity.badRequest().body(ApiResponse.error("手机号格式不正确"));
            }
            
            // 验证验证码
            if (!smsService.verifyCode(phone, code)) {
                return ResponseEntity.badRequest().body(ApiResponse.error("验证码不正确或已过期"));
            }
            
            // 检查手机号是否已被使用
            if (userService.existsByPhone(phone)) {
                return ResponseEntity.badRequest().body(ApiResponse.error("该手机号已被绑定"));
            }
            
            // 绑定手机号
            user.setPhone(phone);
            userService.saveUser(user);
            
            Map<String, Object> result = new HashMap<>();
            result.put("message", "手机号绑定成功");
            result.put("phone", phone);
            result.put("timestamp", System.currentTimeMillis());
            
            log.info("用户 {} 绑定手机号成功: {}", username, phone);
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("绑定手机号失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("绑定手机号失败: " + e.getMessage()));
        }
    }

    /**
     * 获取安全设置状态
     */
    @GetMapping("/status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSecurityStatus(Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            
            Map<String, Object> status = new HashMap<>();
            status.put("hasPassword", user.getPassword() != null && !user.getPassword().isEmpty());
            status.put("hasPhone", user.getPhone() != null && !user.getPhone().isEmpty());
            status.put("hasEmail", user.getEmail() != null && !user.getEmail().isEmpty());
            status.put("phone", user.getPhone());
            status.put("email", user.getEmail());
            status.put("lastPasswordChange", user.getUpdatedAt() != null ? java.sql.Timestamp.valueOf(user.getUpdatedAt()).getTime() : null);
            
            // 如果有手机号，添加验证码相关信息
            if (user.getPhone() != null && !user.getPhone().isEmpty()) {
                status.put("remainingAttempts", smsService.getRemainingAttempts(user.getPhone()));
                status.put("isBlocked", smsService.isBlocked(user.getPhone()));
            }
            
            return ResponseEntity.ok(ApiResponse.success(status));
        } catch (Exception e) {
            log.error("获取安全状态失败: {}", e.getMessage(), e);
            return ResponseEntity.badRequest().body(ApiResponse.error("获取安全状态失败: " + e.getMessage()));
        }
    }
}