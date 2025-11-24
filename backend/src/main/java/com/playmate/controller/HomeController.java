package com.playmate.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class HomeController {
    
    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("name", "陪玩伴侣后端服务");
        response.put("version", "1.0.0");
        response.put("status", "运行中");
        response.put("api_doc", "请访问 /api/health 查看健康状态");
        response.put("endpoints", Map.of(
            "健康检查", "/api/health",
            "用户登录", "POST /api/auth/login",
            "用户注册", "POST /api/auth/register"
        ));
        return response;
    }
}
