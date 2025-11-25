package com.playmate.util;

import java.math.BigDecimal;
import java.util.regex.Pattern;

/**
 * 输入验证工具类
 * 提供统一的参数验证方法，确保数据安全性
 */
public class ValidationUtils {

    // 手机号正则表达式
    private static final Pattern PHONE_PATTERN = Pattern.compile("^1[3-9]\\d{9}$");

    // 邮箱正则表达式
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");

    // 用户名正则表达式（4-20位，字母数字下划线）
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{4,20}$");

    /**
     * 验证手机号格式
     */
    public static boolean isValidPhone(String phone) {
        return phone != null && PHONE_PATTERN.matcher(phone).matches();
    }

    /**
     * 验证邮箱格式
     */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }

    /**
     * 验证用户名格式
     */
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }

    /**
     * 验证密码强度
     * 至少8位，包含大小写字母和数字
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        return password.matches(".*[A-Z].*") &&
                password.matches(".*[a-z].*") &&
                password.matches(".*\\d.*");
    }

    /**
     * 验证金额是否为正数
     */
    public static boolean isValidAmount(BigDecimal amount) {
        return amount != null && amount.compareTo(BigDecimal.ZERO) > 0;
    }

    /**
     * 验证金额范围
     */
    public static boolean isValidAmountRange(BigDecimal amount, BigDecimal min, BigDecimal max) {
        return isValidAmount(amount) &&
                amount.compareTo(min) >= 0 &&
                amount.compareTo(max) <= 0;
    }

    /**
     * 验证字符串长度
     */
    public static boolean isValidLength(String str, int minLength, int maxLength) {
        return str != null &&
                str.length() >= minLength &&
                str.length() <= maxLength;
    }

    /**
     * 验证ID是否有效（正数）
     */
    public static boolean isValidId(Long id) {
        return id != null && id > 0;
    }

    /**
     * 验证服务时长（分钟）
     */
    public static boolean isValidDuration(Integer duration) {
        return duration != null && duration > 0 && duration <= 480; // 最多8小时
    }

    /**
     * 清理和验证输入字符串，防止XSS攻击
     */
    public static String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        // 移除潜在的HTML标签和脚本
        String cleaned = input.replaceAll("<[^>]*>", "")
                .replaceAll("(?i)javascript:", "")
                .replaceAll("on\\w+\\s*=", "")
                .trim();
        // 去除常见的脚本调用或敏感关键词（不区分大小写）
        cleaned = cleaned.replaceAll("(?i)\\b(alert|prompt|eval|console)\\b", "");
        // 去除剩余的括号内容（如 alert(...)）
        cleaned = cleaned.replaceAll("\\([^\\)]*\\)", "");
        return cleaned.trim();
    }

    /**
     * 验证订单号格式
     */
    public static boolean isValidOrderNo(String orderNo) {
        return orderNo != null &&
                orderNo.startsWith("PM") &&
                orderNo.length() >= 10 &&
                orderNo.matches("^[A-Z0-9]+$");
    }

    /**
     * 验证支付号格式
     */
    public static boolean isValidPaymentNo(String paymentNo) {
        return paymentNo != null &&
                paymentNo.startsWith("PAY") &&
                paymentNo.length() >= 10 &&
                paymentNo.matches("^[A-Z0-9]+$");
    }

    /**
     * 验证交易ID格式
     */
    public static boolean isValidTransactionId(String transactionId) {
        return transactionId != null &&
                transactionId.length() >= 10 &&
                transactionId.length() <= 100 &&
                transactionId.matches("^[a-zA-Z0-9_]+$");
    }
}