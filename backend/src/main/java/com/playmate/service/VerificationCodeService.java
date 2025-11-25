package com.playmate.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("null")
public class VerificationCodeService {

    @Autowired(required = false)
    private StringRedisTemplate redisTemplate;

    private final Random random = new SecureRandom();

    private static final int CODE_LENGTH = 6;
    private static final Duration CODE_EXPIRATION = Duration.ofMinutes(5);
    private static final int MAX_ATTEMPTS = 5;
    private static final Duration ATTEMPTS_EXPIRATION = Duration.ofHours(1);

    // In-memory fallback storage when Redis is not available
    private final Map<String, CodeEntry> codeStore = new ConcurrentHashMap<>();
    private final Map<String, AttemptsEntry> attemptsStore = new ConcurrentHashMap<>();

    private static class CodeEntry {
        String code;
        Instant expiry;

        CodeEntry(String code, Instant expiry) {
            this.code = code;
            this.expiry = expiry;
        }
    }

    private static class AttemptsEntry {
        int attempts;
        Instant expiry;

        AttemptsEntry(int attempts, Instant expiry) {
            this.attempts = attempts;
            this.expiry = expiry;
        }
    }

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
     * 存储验证码
     */
    public void storeCode(String phone, String code) {
        if (redisTemplate != null) {
            String key = "verification_code:" + phone;
            redisTemplate.opsForValue().set(key, code, CODE_EXPIRATION);
            log.info("验证码已存储(Redis): {} -> {}", phone, code);
            return;
        }

        Instant expiry = Instant.now().plus(CODE_EXPIRATION);
        codeStore.put(phone, new CodeEntry(code, expiry));
        log.info("验证码已存储(InMemory): {} -> {}", phone, code);
    }

    /**
     * 验证验证码
     */
    public boolean verifyCode(String phone, String inputCode) {
        if (redisTemplate != null) {
            String key = "verification_code:" + phone;
            String storedCode = redisTemplate.opsForValue().get(key);

            if (storedCode == null) {
                log.warn("验证码不存在或已过期(Redis): {}", phone);
                return false;
            }

            if (!storedCode.equals(inputCode)) {
                incrementAttempts(phone);
                log.warn("验证码错误(Redis): {} -> {}", phone, inputCode);
                return false;
            }

            // 验证成功，删除验证码
            redisTemplate.delete(key);
            clearAttempts(phone);
            log.info("验证码验证成功(Redis): {}", phone);
            return true;
        }

        CodeEntry entry = codeStore.get(phone);
        if (entry == null || Instant.now().isAfter(entry.expiry)) {
            log.warn("验证码不存在或已过期(InMemory): {}", phone);
            return false;
        }

        if (!entry.code.equals(inputCode)) {
            incrementAttempts(phone);
            log.warn("验证码错误(InMemory): {} -> {}", phone, inputCode);
            return false;
        }

        // 验证成功
        codeStore.remove(phone);
        clearAttempts(phone);
        log.info("验证码验证成功(InMemory): {}", phone);
        return true;
    }

    /**
     * 检查是否可以发送验证码
     */
    public boolean canSendCode(String phone) {
        if (redisTemplate != null) {
            String key = "verification_code:" + phone;
            String code = redisTemplate.opsForValue().get(key);
            if (code != null) {
                log.warn("验证码未过期，不能重复发送(Redis): {}", phone);
                return false;
            }
            return !isBlocked(phone);
        }

        CodeEntry entry = codeStore.get(phone);
        if (entry != null && Instant.now().isBefore(entry.expiry)) {
            log.warn("验证码未过期，不能重复发送(InMemory): {}", phone);
            return false;
        }

        return !isBlocked(phone);
    }

    /**
     * 增加验证失败次数
     */
    private void incrementAttempts(String phone) {
        if (redisTemplate != null) {
            String key = "verification_attempts:" + phone;
            Long attempts = redisTemplate.opsForValue().increment(key);
            if (attempts != null && attempts == 1) {
                redisTemplate.expire(key, ATTEMPTS_EXPIRATION);
            }
            if (attempts != null && attempts >= MAX_ATTEMPTS) {
                log.warn("验证码尝试次数过多，已被阻止(Redis): {}", phone);
            }
            return;
        }

        AttemptsEntry entry = attemptsStore.get(phone);
        if (entry == null || Instant.now().isAfter(entry.expiry)) {
            attemptsStore.put(phone, new AttemptsEntry(1, Instant.now().plus(ATTEMPTS_EXPIRATION)));
        } else {
            entry.attempts++;
            attemptsStore.put(phone, entry);
            if (entry.attempts >= MAX_ATTEMPTS) {
                log.warn("验证码尝试次数过多，已被阻止(InMemory): {}", phone);
            }
        }
    }

    /**
     * 检查是否被阻止
     */
    public boolean isBlocked(String phone) {
        if (redisTemplate != null) {
            String key = "verification_attempts:" + phone;
            String attempts = redisTemplate.opsForValue().get(key);
            if (attempts != null && Integer.parseInt(attempts) >= MAX_ATTEMPTS) {
                return true;
            }
            return false;
        }

        AttemptsEntry entry = attemptsStore.get(phone);
        if (entry == null || Instant.now().isAfter(entry.expiry)) {
            return false;
        }
        return entry.attempts >= MAX_ATTEMPTS;
    }

    /**
     * 清除尝试次数
     */
    private void clearAttempts(String phone) {
        if (redisTemplate != null) {
            String key = "verification_attempts:" + phone;
            redisTemplate.delete(key);
            return;
        }

        attemptsStore.remove(phone);
    }

    /**
     * 获取剩余尝试次数
     */
    public int getRemainingAttempts(String phone) {
        if (redisTemplate != null) {
            String key = "verification_attempts:" + phone;
            String attempts = redisTemplate.opsForValue().get(key);
            if (attempts == null) {
                return MAX_ATTEMPTS;
            }
            return Math.max(0, MAX_ATTEMPTS - Integer.parseInt(attempts));
        }

        AttemptsEntry entry = attemptsStore.get(phone);
        if (entry == null || Instant.now().isAfter(entry.expiry)) {
            return MAX_ATTEMPTS;
        }
        return Math.max(0, MAX_ATTEMPTS - entry.attempts);
    }

    /**
     * 删除验证码
     */
    public void deleteCode(String phone) {
        if (redisTemplate != null) {
            String key = "verification_code:" + phone;
            redisTemplate.delete(key);
            clearAttempts(phone);
            return;
        }

        codeStore.remove(phone);
        clearAttempts(phone);
    }
}