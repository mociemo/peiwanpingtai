package com.playmate.controller;

import com.playmate.dto.ApiResponse;
import com.playmate.service.PlayerServiceManager;
import com.playmate.entity.PlayerService;
import com.playmate.entity.User;
import com.playmate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/players")
@RequiredArgsConstructor
public class PlayerController {
    
    private final PlayerServiceManager playerServiceManager;
    private final UserRepository userRepository;
    
    @PostMapping("/services")
    public ResponseEntity<ApiResponse<PlayerService>> addPlayerService(
            Authentication authentication,
            @RequestBody Map<String, Object> serviceData) {
        try {
            String username = authentication.getName();
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("用户不存在"));
            
            String serviceName = (String) serviceData.get("serviceName");
            String serviceDescription = (String) serviceData.get("serviceDescription");
            BigDecimal servicePrice = new BigDecimal(serviceData.get("servicePrice").toString());
            Integer durationMinutes = (Integer) serviceData.get("durationMinutes");
            PlayerService.ServiceType serviceType = PlayerService.ServiceType.valueOf((String) serviceData.get("serviceType"));
            
            // 参数非空验证
            if (serviceName == null || serviceDescription == null || servicePrice == null || 
                durationMinutes == null || serviceType == null) {
                throw new IllegalArgumentException("服务参数不能为空");
            }
            
            Long userId = user.getId();
            if (userId == null) {
                throw new IllegalStateException("用户ID不能为空");
            }
            
            PlayerService result = playerServiceManager.addPlayerService(
                userId, serviceName, serviceDescription, 
                servicePrice, durationMinutes, serviceType
            );
            return ResponseEntity.ok(ApiResponse.success("添加服务成功", result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/{playerId}/services")
    public ResponseEntity<ApiResponse<List<PlayerService>>> getPlayerServices(@PathVariable Long playerId) {
        try {
            if (playerId == null) {
                throw new IllegalArgumentException("玩家ID不能为空");
            }
            List<PlayerService> services = playerServiceManager.getPlayerServices(playerId);
            return ResponseEntity.ok(ApiResponse.success(services));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/services")
    public ResponseEntity<ApiResponse<List<PlayerService>>> getAllPlayerServices() {
        try {
            List<PlayerService> services = playerServiceManager.getAllPlayerServices();
            return ResponseEntity.ok(ApiResponse.success(services));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/services/type/{serviceType}")
    public ResponseEntity<ApiResponse<List<PlayerService>>> getServicesByType(@PathVariable PlayerService.ServiceType serviceType) {
        try {
            List<PlayerService> services = playerServiceManager.getServicesByType(serviceType);
            return ResponseEntity.ok(ApiResponse.success(services));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}