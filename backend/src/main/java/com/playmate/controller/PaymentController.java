package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.Payment;
import com.playmate.entity.User;

import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;


import java.util.*;

@RestController
@RequestMapping("/api/payment")
@RequiredArgsConstructor
public class PaymentController {

    private final UserService userService;

    /**
     * 获取支付方式列表
     */
    @GetMapping("/methods")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getPaymentMethods() {
        try {
            List<Map<String, Object>> methods = new ArrayList<>();
            
            for (Payment.PaymentMethod method : Payment.PaymentMethod.values()) {
                Map<String, Object> methodInfo = new HashMap<>();
                methodInfo.put("id", method.name());
                methodInfo.put("type", method.name().toLowerCase());
                methodInfo.put("name", getDisplayName(method));
                methodInfo.put("description", getDescription(method));
                methodInfo.put("enabled", true);
                methodInfo.put("icon", getIconName(method));
                methods.add(methodInfo);
            }
            
            return ResponseEntity.ok(ApiResponse.success(methods));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取支付方式失败: " + e.getMessage()));
        }
    }

    /**
     * 获取用户支付设置
     */
    @GetMapping("/settings")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getPaymentSettings(Authentication authentication) {
        try {
            // 模拟用户支付设置
            Map<String, Object> settings = new HashMap<>();
            settings.put("autoRechargeEnabled", false);
            settings.put("selectedRechargeAmount", 50.0);
            settings.put("biometricPaymentEnabled", false);
            settings.put("paymentNotificationEnabled", true);
            settings.put("defaultPaymentMethod", Payment.PaymentMethod.WALLET.name());
            
            return ResponseEntity.ok(ApiResponse.success(settings));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取支付设置失败: " + e.getMessage()));
        }
    }

    /**
     * 更新支付设置
     */
    @PutMapping("/settings")
    public ResponseEntity<ApiResponse<Map<String, Object>>> updatePaymentSettings(
            Authentication authentication,
            @RequestBody Map<String, Object> settings) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            
            // 这里应该保存到数据库，暂时返回设置数据
            Map<String, Object> result = new HashMap<>();
            result.putAll(settings);
            result.put("userId", user.getId());
            result.put("updatedAt", System.currentTimeMillis());
            
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新支付设置失败: " + e.getMessage()));
        }
    }

    private String getDisplayName(Payment.PaymentMethod method) {
        switch (method) {
            case WALLET: return "余额支付";
            case ALIPAY: return "支付宝";
            case WECHAT: return "微信支付";
            default: return method.name();
        }
    }

    private String getDescription(Payment.PaymentMethod method) {
        switch (method) {
            case WALLET: return "使用账户余额支付";
            case ALIPAY: return "使用支付宝余额或银行卡支付";
            case WECHAT: return "使用微信余额或银行卡支付";
            default: return "";
        }
    }

    private String getIconName(Payment.PaymentMethod method) {
        switch (method) {
            case WALLET: return "wallet";
            case ALIPAY: return "alipay";
            case WECHAT: return "wechat";
            default: return "payment";
        }
    }
}