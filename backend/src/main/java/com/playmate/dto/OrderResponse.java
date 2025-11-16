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
    private Order.OrderStatus status;
    private Order.ServiceType serviceType;
    private String requirements;
    private String contactInfo;
    private LocalDateTime createTime;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String cancelReason;
    private String rating;
    private String comment;
    private LocalDateTime commentTime;
    
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