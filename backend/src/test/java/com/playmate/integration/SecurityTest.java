package com.playmate.integration;

import com.playmate.util.ValidationUtils;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 安全性测试
 * 测试输入验证、XSS防护等安全功能
 */
@SpringBootTest
@ActiveProfiles("test")
public class SecurityTest {

    @Test
    public void testPhoneValidation() {
        // 有效手机号
        assertTrue(ValidationUtils.isValidPhone("13800138000"));
        assertTrue(ValidationUtils.isValidPhone("15912345678"));
        
        // 无效手机号
        assertFalse(ValidationUtils.isValidPhone("12800138000"));
        assertFalse(ValidationUtils.isValidPhone("1380013800"));
        assertFalse(ValidationUtils.isValidPhone("138001380001"));
        assertFalse(ValidationUtils.isValidPhone("abc12345678"));
        assertFalse(ValidationUtils.isValidPhone(null));
    }

    @Test
    public void testEmailValidation() {
        // 有效邮箱
        assertTrue(ValidationUtils.isValidEmail("test@example.com"));
        assertTrue(ValidationUtils.isValidEmail("user.name@domain.co.uk"));
        
        // 无效邮箱
        assertFalse(ValidationUtils.isValidEmail("test@"));
        assertFalse(ValidationUtils.isValidEmail("@example.com"));
        assertFalse(ValidationUtils.isValidEmail("test.example.com"));
        assertFalse(ValidationUtils.isValidEmail(null));
    }

    @Test
    public void testUsernameValidation() {
        // 有效用户名
        assertTrue(ValidationUtils.isValidUsername("testuser"));
        assertTrue(ValidationUtils.isValidUsername("user_123"));
        assertTrue(ValidationUtils.isValidUsername("User123"));
        
        // 无效用户名
        assertFalse(ValidationUtils.isValidUsername("us")); // 太短
        assertFalse(ValidationUtils.isValidUsername("verylongusernamethatexceedslimit")); // 太长
        assertFalse(ValidationUtils.isValidUsername("user@name")); // 包含特殊字符
        assertFalse(ValidationUtils.isValidUsername(null));
    }

    @Test
    public void testPasswordValidation() {
        // 有效密码
        assertTrue(ValidationUtils.isValidPassword("Password123"));
        assertTrue(ValidationUtils.isValidPassword("MySecurePass1"));
        
        // 无效密码
        assertFalse(ValidationUtils.isValidPassword("password")); // 没有大写字母和数字
        assertFalse(ValidationUtils.isValidPassword("PASSWORD123")); // 没有小写字母
        assertFalse(ValidationUtils.isValidPassword("Password")); // 没有数字
        assertFalse(ValidationUtils.isValidPassword("Pass1")); // 太短
        assertFalse(ValidationUtils.isValidPassword(null));
    }

    @Test
    public void testAmountValidation() {
        // 有效金额
        assertTrue(ValidationUtils.isValidAmount(java.math.BigDecimal.valueOf(100)));
        assertTrue(ValidationUtils.isValidAmount(java.math.BigDecimal.valueOf(0.01)));
        
        // 无效金额
        assertFalse(ValidationUtils.isValidAmount(null));
        assertFalse(ValidationUtils.isValidAmount(java.math.BigDecimal.ZERO));
        assertFalse(ValidationUtils.isValidAmount(java.math.BigDecimal.valueOf(-100)));
    }

    @Test
    public void testInputSanitization() {
        // XSS攻击测试
        String maliciousInput = "<script>alert('xss')</script>";
        String sanitized = ValidationUtils.sanitizeInput(maliciousInput);
        
        assertFalse(sanitized.contains("<script>"));
        assertFalse(sanitized.contains("alert"));
        assertFalse(sanitized.contains("javascript:"));
    }

    @Test
    public void testOrderNoValidation() {
        // 有效订单号
        assertTrue(ValidationUtils.isValidOrderNo("PM1234567890ABCD"));
        
        // 无效订单号
        assertFalse(ValidationUtils.isValidOrderNo("PM123"));
        assertFalse(ValidationUtils.isValidOrderNo("ORD1234567890"));
        assertFalse(ValidationUtils.isValidOrderNo(null));
    }

    @Test
    public void testTransactionIdValidation() {
        // 有效交易ID
        assertTrue(ValidationUtils.isValidTransactionId("TX1234567890ABC"));
        assertTrue(ValidationUtils.isValidTransactionId("transaction_id_123"));
        
        // 无效交易ID
        assertFalse(ValidationUtils.isValidTransactionId("TX123")); // 太短
        assertFalse(ValidationUtils.isValidTransactionId("TX" + "a".repeat(101))); // 太长
        assertFalse(ValidationUtils.isValidTransactionId("TX@123")); // 包含特殊字符
        assertFalse(ValidationUtils.isValidTransactionId(null));
    }
}