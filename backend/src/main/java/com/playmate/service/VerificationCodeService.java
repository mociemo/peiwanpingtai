package com.playmate.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.Random;

@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("null")
public class VerificationCodeService {
    
    private final StringRedisTemplate redisTemplate;
    private final Random random = new SecureRandom();
    
    private static final String CODE_PREFIX = "verification_code:";
    private static final int CODE_LENGTH = 6;
    private static final Duration CODE_EXPIRATION = Duration.ofMinutes(5);
    private static final int MAX_ATTEMPTS = 5;
    private static final String ATTEMPTS_PREFIX = "verification_attempts:";
    
    /**
     * 生成验证码
     */
    public String generateCode() {
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < CODE_LENGTH; i++) {
            code.append(random.nextInt(10));
        }
        return code.toString();
    }
    
    /**
     * 存储验证码到Redis
     */
    public void storeCode(String phone, String code) {
        String key = CODE_PREFIX + phone;
        redisTemplate.opsForValue().set(key, code, CODE_EXPIRATION);
        log.info("验证码已存储: {} -> {}", phone, code);
    }
    
    /**
     * 验证验证码
     */
    public boolean verifyCode(String phone, String inputCode) {
        String key = CODE_PREFIX + phone;
        String storedCode = redisTemplate.opsForValue().get(key);
        
        if (storedCode == null) {
            log.warn("验证码不存在或已过期: {}", phone);
            return false;
        }
        
        if (!storedCode.equals(inputCode)) {
            incrementAttempts(phone);
            log.warn("验证码错误: {} -> {}", phone, inputCode);
            return false;
        }
        
        // 验证成功，删除验证码
        redisTemplate.delete(key);
        clearAttempts(phone);
        log.info("验证码验证成功: {}", phone);
        return true;
    }
    
    /**
     * 检查是否可以发送验证码
     */
    public boolean canSendCode(String phone) {
        String key = CODE_PREFIX + phone;
        String code = redisTemplate.opsForValue().get(key);
        
        // 如果已有验证码且未过期，不能重复发送
        if (code != null) {
            log.warn("验证码未过期，不能重复发送: {}", phone);
            return false;
        }
        
        // 检查尝试次数
        return !isBlocked(phone);
    }
    
    /**
     * 增加验证失败次数
     */
    private void incrementAttempts(String phone) {
        String key = ATTEMPTS_PREFIX + phone;
        Long attempts = redisTemplate.opsForValue().increment(key);
        
        if (attempts != null && attempts == 1) {
            redisTemplate.expire(key, Duration.ofHours(1));
        }
        
        if (attempts != null && attempts >= MAX_ATTEMPTS) {
            log.warn("验证码尝试次数过多，已被阻止: {}", phone);
        }
    }
    
    /**
     * 检查是否被阻止
     */
    public boolean isBlocked(String phone) {
        String key = ATTEMPTS_PREFIX + phone;
        String attempts = redisTemplate.opsForValue().get(key);
        
        if (attempts != null && Integer.parseInt(attempts) >= MAX_ATTEMPTS) {
            return true;
        }
        
        return false;
    }
    
    /**
     * 清除尝试次数
     */
    private void clearAttempts(String phone) {
        String key = ATTEMPTS_PREFIX + phone;
        redisTemplate.delete(key);
    }
    
    /**
     * 获取剩余尝试次数
     */
    public int getRemainingAttempts(String phone) {
        String key = ATTEMPTS_PREFIX + phone;
        String attempts = redisTemplate.opsForValue().get(key);
        
        if (attempts == null) {
            return MAX_ATTEMPTS;
        }
        
        return Math.max(0, MAX_ATTEMPTS - Integer.parseInt(attempts));
    }
    
    /**
     * 删除验证码
     */
    public void deleteCode(String phone) {
        String key = CODE_PREFIX + phone;
        redisTemplate.delete(key);
        clearAttempts(phone);
    }
}