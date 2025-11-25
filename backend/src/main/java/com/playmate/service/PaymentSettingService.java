package com.playmate.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.playmate.entity.PaymentSetting;
import com.playmate.entity.User;
import com.playmate.repository.PaymentSettingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentSettingService {

    private final PaymentSettingRepository repository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public PaymentSetting getByUser(User user) {
        return repository.findByUser(user).orElse(null);
    }

    public PaymentSetting saveOrUpdate(User user, Map<String, Object> settings) {
        try {
            PaymentSetting ps = repository.findByUser(user).orElse(new PaymentSetting());
            ps.setUser(user);
            String json = objectMapper.writeValueAsString(settings);
            ps.setSettings(json);
            return repository.save(ps);
        } catch (Exception e) {
            log.error("保存支付设置失败", e);
            throw new RuntimeException("保存支付设置失败: " + e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> parseSettings(PaymentSetting ps) {
        if (ps == null || ps.getSettings() == null)
            return null;
        try {
            return objectMapper.readValue(ps.getSettings(), Map.class);
        } catch (Exception e) {
            log.warn("解析支付设置JSON失败", e);
            return null;
        }
    }
}
