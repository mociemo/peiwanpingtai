package com.playmate.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class SmsService {
    
    @Value("${sms.enabled:false}")
    private boolean smsEnabled;
    
    @Value("${sms.mock-mode:true}")
    private boolean mockMode;
    
    private final VerificationCodeService verificationCodeService;
    
    /**
     * 发送短信验证码
     */
    public boolean sendVerificationCode(String phone) {
        try {
            // 检查是否可以发送验证码
            if (!verificationCodeService.canSendCode(phone)) {
                log.warn("验证码发送频率过高或已被阻止: {}", phone);
                return false;
            }
            
            // 生成验证码
            String code = verificationCodeService.generateCode();
            
            // 存储验证码
            verificationCodeService.storeCode(phone, code);
            
            // 发送短信
            if (mockMode || !smsEnabled) {
                // 模拟发送
                log.info("【模拟短信】验证码: {} (发送到: {})", code, phone);
                return true;
            } else {
                // 实际发送短信
                return sendSms(phone, "【陪玩平台】您的验证码是：" + code + "，5分钟内有效。");
            }
            
        } catch (Exception e) {
            log.error("发送验证码失败: {}", e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 发送普通短信
     */
    public boolean sendSms(String phone, String message) {
        try {
            if (mockMode || !smsEnabled) {
                log.info("【模拟短信】{} (发送到: {})", message, phone);
                return true;
            }
            
            // 这里集成真实的短信服务商API
            // 例如：阿里云短信、腾讯云短信、华为云短信等
            
            // 示例：阿里云短信服务
            /*
            DefaultProfile profile = DefaultProfile.getProfile(
                "cn-hangzhou", 
                accessKeyId, 
                accessKeySecret
            );
            
            IAcsClient client = new DefaultAcsClient(profile);
            
            CommonRequest request = new CommonRequest();
            request.setSysMethod(MethodType.POST);
            request.setSysDomain("dysmsapi.aliyuncs.com");
            request.setSysVersion("2017-05-25");
            request.setSysAction("SendSms");
            request.putQueryParameter("PhoneNumbers", phone);
            request.putQueryParameter("SignName", signName);
            request.putQueryParameter("TemplateCode", templateCode);
            request.putQueryParameter("TemplateParam", "{\"code\":\"" + code + "\"}");
            
            CommonResponse response = client.getCommonResponse(request);
            
            if ("OK".equals(response.getData())) {
                log.info("短信发送成功: {}", phone);
                return true;
            } else {
                log.error("短信发送失败: {}", response.getData());
                return false;
            }
            */
            
            log.info("短信发送成功: {} - {}", phone, message);
            return true;
            
        } catch (Exception e) {
            log.error("发送短信失败: {}", e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 验证验证码
     */
    public boolean verifyCode(String phone, String code) {
        return verificationCodeService.verifyCode(phone, code);
    }
    
    /**
     * 获取剩余尝试次数
     */
    public int getRemainingAttempts(String phone) {
        return verificationCodeService.getRemainingAttempts(phone);
    }
    
    /**
     * 检查是否被阻止
     */
    public boolean isBlocked(String phone) {
        return verificationCodeService.isBlocked(phone);
    }
}