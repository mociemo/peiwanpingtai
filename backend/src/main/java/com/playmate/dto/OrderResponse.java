package com.playmate.dto;

import com.playmate.entity.Order;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class OrderResponse {
    private Long id;
    private String orderNo;
    private UserInfo user;
    private PlayerInfo player;
    private BigDecimal amount;
    private Integer duration;
    private String status;
    private String serviceType;
    private String requirements;
    private String contactInfo;
    private LocalDateTime createTime;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String cancelReason;
    private String rating;
    private String comment;
    private LocalDateTime commentTime;
    
    // Manual setters for Lombok compatibility
    public void setId(Long id) {
        this.id = id;
    }
    
    public void setUserId(String userId) {
        // 这个方法可能不需要，因为OrderResponse使用UserInfo对象
    }
    
    public void setPlayerId(String playerId) {
        // 这个方法可能不需要，因为OrderResponse使用PlayerInfo对象
    }
    
    public void setGameId(String gameId) {
        // 这个方法可能不需要
    }
    
    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }
    
    public void setDuration(Integer duration) {
        this.duration = duration;
    }
    
    public void setRequirements(String requirements) {
        this.requirements = requirements;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
    
    @Data
    public static class UserInfo {
        private Long id;
        private String username;
        private String avatar;
    }
    
    @Data
    public static class PlayerInfo {
        private Long id;
        private String username;
        private String avatar;
        private String game;
        private BigDecimal price;
    }
}