package com.playmate.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "players")
@Data
public class Player {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "real_name")
    private String realName;
    
    @Column(name = "id_card")
    private String idCard;
    
    @Column(columnDefinition = "JSON")
    private String skillTags;
    
    @Column(name = "service_price", precision = 10, scale = 2)
    private BigDecimal servicePrice;
    
    @Lob
    private String introduction;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "certification_status")
    private CertificationStatus certificationStatus;
    
    @Column(name = "total_orders", nullable = false)
    private Integer totalOrders = 0;
    
    @Column(precision = 3, scale = 2, nullable = false)
    private BigDecimal rating = BigDecimal.valueOf(5.0);
    
    @Column(columnDefinition = "JSON")
    private String availableTime;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    // 游戏专长
    @Column
    private String game;
    
    public enum CertificationStatus {
        PENDING, APPROVED, REJECTED
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}