package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.entity.User;
import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/info")
    public ResponseEntity<ApiResponse<User>> getUserInfo(Authentication authentication) {
        try {
            String username = authentication.getName();
            if (username == null) {
                throw new IllegalStateException("用户认证信息无效");
            }
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            
            // 隐藏敏感信息
            user.setPassword(null);
            
            return ResponseEntity.ok(ApiResponse.success(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取用户信息失败"));
        }
    }
    
    @PutMapping("/info")
    public ResponseEntity<ApiResponse<User>> updateUserInfo(
            Authentication authentication,
            @RequestBody Map<String, Object> userData) {
        try {
            String username = authentication.getName();
            if (username == null) {
                throw new IllegalStateException("用户认证信息无效");
            }
            User user = userService.updateUserInfo(username, userData);
            
            // 隐藏敏感信息
            user.setPassword(null);
            
            return ResponseEntity.ok(ApiResponse.success("更新成功", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/apply-player")
    public ResponseEntity<ApiResponse<User>> applyForPlayer(Authentication authentication) {
        try {
            String username = authentication.getName();
            if (username == null) {
                throw new IllegalStateException("用户认证信息无效");
            }
            User user = userService.applyForPlayer(username, null);
            
            return ResponseEntity.ok(ApiResponse.success("申请已提交，等待审核", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}