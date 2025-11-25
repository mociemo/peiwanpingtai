package com.playmate.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "player_services")
public class PlayerService {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "player_id", nullable = false)
    private Player player;
    
    @Column(name = "service_name", nullable = false)
    private String serviceName;
    
    @Column(name = "service_description", columnDefinition = "TEXT")
    private String serviceDescription;
    
    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal servicePrice;
    
    @Column(name = "duration_minutes", nullable = false)
    private Integer durationMinutes;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "service_type", nullable = false)
    private ServiceType serviceType;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ServiceStatus status = ServiceStatus.ACTIVE;
    
    @Column(name = "max_orders_per_day")
    private Integer maxOrdersPerDay;
    
    @Column(name = "current_orders_today")
    private Integer currentOrdersToday = 0;
    
    @Column(name = "total_orders")
    private Integer totalOrders = 0;
    
    @Column(name = "rating", precision = 3, scale = 2)
    private BigDecimal rating = BigDecimal.ZERO;
    
    @Column(name = "rating_count")
    private Integer ratingCount = 0;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    public enum ServiceType {
        GAME_ACCOMPANY,    // 游戏陪玩
        VOICE_CHAT,        // 语音聊天
        VIDEO_CHAT,        // 视频聊天
        SKILL_TEACHING,    // 技能教学
        EMOTIONAL_SUPPORT, // 情感陪伴
        CUSTOM             // 自定义服务
    }
    
    public enum ServiceStatus {
        ACTIVE,    // 激活
        INACTIVE,  // 停用
        SUSPENDED  // 暂停
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Player getPlayer() { return player; }
    public void setPlayer(Player player) { this.player = player; }
    
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    
    public String getServiceDescription() { return serviceDescription; }
    public void setServiceDescription(String serviceDescription) { this.serviceDescription = serviceDescription; }
    
    public BigDecimal getServicePrice() { return servicePrice; }
    public void setServicePrice(BigDecimal servicePrice) { this.servicePrice = servicePrice; }
    
    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }
    
    public ServiceType getServiceType() { return serviceType; }
    public void setServiceType(ServiceType serviceType) { this.serviceType = serviceType; }
    
    public ServiceStatus getStatus() { return status; }
    public void setStatus(ServiceStatus status) { this.status = status; }
    
    public Integer getMaxOrdersPerDay() { return maxOrdersPerDay; }
    public void setMaxOrdersPerDay(Integer maxOrdersPerDay) { this.maxOrdersPerDay = maxOrdersPerDay; }
    
    public Integer getCurrentOrdersToday() { return currentOrdersToday; }
    public void setCurrentOrdersToday(Integer currentOrdersToday) { this.currentOrdersToday = currentOrdersToday; }
    
    public Integer getTotalOrders() { return totalOrders; }
    public void setTotalOrders(Integer totalOrders) { this.totalOrders = totalOrders; }
    
    public BigDecimal getRating() { return rating; }
    public void setRating(BigDecimal rating) { this.rating = rating; }
    
    public Integer getRatingCount() { return ratingCount; }
    public void setRatingCount(Integer ratingCount) { this.ratingCount = ratingCount; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}