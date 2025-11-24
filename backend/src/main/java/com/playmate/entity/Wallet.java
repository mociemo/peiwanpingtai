package com.playmate.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallets")
@Data
public class Wallet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal balance = BigDecimal.ZERO;
    
    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal frozenBalance = BigDecimal.ZERO;
    
    @Column(name = "total_recharge", precision = 10, scale = 2, nullable = false)
    private BigDecimal totalRecharge = BigDecimal.ZERO;
    
    @Column(name = "total_withdraw", precision = 10, scale = 2, nullable = false)
    private BigDecimal totalWithdraw = BigDecimal.ZERO;
    
    @Column(name = "total_income", precision = 10, scale = 2, nullable = false)
    private BigDecimal totalIncome = BigDecimal.ZERO;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}