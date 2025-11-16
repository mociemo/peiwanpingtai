package com.playmate.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
@Data
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String orderNo;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;
    
    @Column(nullable = false)
    private BigDecimal amount;
    
    @Column(nullable = false)
    private Integer duration; // 时长（分钟）
    
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private OrderStatus status;
    
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private ServiceType serviceType;
    
    @Column(length = 500)
    private String requirements;
    
    @Column
    private String contactInfo;
    
    @Column(nullable = false)
    private LocalDateTime createTime;
    
    @Column
    private LocalDateTime startTime;
    
    @Column
    private LocalDateTime endTime;
    
    @Column
    private String cancelReason;
    
    @Column
    private String rating;
    
    @Column
    private String comment;
    
    @Column
    private LocalDateTime commentTime;
    
    public enum OrderStatus {
        PENDING,        // 待接单
        ACCEPTED,       // 已接单
        IN_PROGRESS,    // 进行中
        COMPLETED,      // 已完成
        CANCELLED,      // 已取消
        REFUNDED        // 已退款
    }
    
    public enum ServiceType {
        VOICE,          // 语音陪玩
        VIDEO,          // 视频陪玩
        GAME_GUIDE,     // 游戏指导
        ENTERTAINMENT   // 娱乐陪玩
    }
}