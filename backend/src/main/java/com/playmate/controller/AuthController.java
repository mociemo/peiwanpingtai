package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.dto.LoginRequest;
import com.playmate.dto.RegisterRequest;
import com.playmate.entity.User;
import com.playmate.security.JwtUtil;
import com.playmate.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserService userService;
    
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Map<String, Object>>> login(@RequestBody LoginRequest request) {
        try {
            // 验证用户凭据
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
            
            // 生成JWT token
            String token = jwtUtil.generateToken(request.getUsername());
            
            // 获取用户信息
            User user = userService.findByUsername(request.getUsername());
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("token", token);
            responseData.put("user", user);
            
            return ResponseEntity.ok(ApiResponse.success("登录成功", responseData));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("用户名或密码错误"));
        }
    }
    
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<User>> register(@RequestBody RegisterRequest request) {
        try {
            // 验证用户名是否已存在
            if (userService.existsByUsername(request.getUsername())) {
                return ResponseEntity.badRequest().body(ApiResponse.error("用户名已存在"));
            }
            
            // 验证手机号是否已存在
            if (userService.existsByPhone(request.getPhone())) {
                return ResponseEntity.badRequest().body(ApiResponse.error("手机号已注册"));
            }
            
            // 验证邮箱是否已存在
            if (request.getEmail() != null && userService.existsByEmail(request.getEmail())) {
                return ResponseEntity.badRequest().body(ApiResponse.error("邮箱已注册"));
            }
            
            // 创建用户
            User user = userService.registerUser(
                request.getUsername(),
                request.getPassword(),
                request.getEmail(),
                request.getPhone(),
                request.getNickname()
            );
            
            return ResponseEntity.ok(ApiResponse.success("注册成功", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/send-code")
    public ResponseEntity<ApiResponse<String>> sendVerificationCode(@RequestParam String phone) {
        try {
            return ResponseEntity.ok(ApiResponse.success("验证码已发送", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("发送验证码失败"));
        }
    }
    
    @PostMapping("/verify-code")
    public ResponseEntity<ApiResponse<Boolean>> verifyCode(@RequestParam String phone, @RequestParam String code) {
        try {
            boolean isValid = true; // 模拟验证成功
            return ResponseEntity.ok(ApiResponse.success("验证成功", isValid));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("验证码验证失败"));
        }
    }
}