package com.playmate.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "players")
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
    
    // 委托方法，通过User对象获取相关信息
    public String getAvatar() {
        return this.user != null ? this.user.getAvatar() : null;
    }
    
    public String getUsername() {
        return this.user != null ? this.user.getUsername() : null;
    }
    
    public BigDecimal getPrice() {
        return this.servicePrice;
    }
    
    // Manual getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
    
    public String getIdCard() { return idCard; }
    public void setIdCard(String idCard) { this.idCard = idCard; }
    
    public String getSkillTags() { return skillTags; }
    public void setSkillTags(String skillTags) { this.skillTags = skillTags; }
    
    public BigDecimal getServicePrice() { return servicePrice; }
    public void setServicePrice(BigDecimal servicePrice) { this.servicePrice = servicePrice; }
    
    public String getIntroduction() { return introduction; }
    public void setIntroduction(String introduction) { this.introduction = introduction; }
    
    public CertificationStatus getCertificationStatus() { return certificationStatus; }
    public void setCertificationStatus(CertificationStatus certificationStatus) { this.certificationStatus = certificationStatus; }
    
    public Integer getTotalOrders() { return totalOrders; }
    public void setTotalOrders(Integer totalOrders) { this.totalOrders = totalOrders; }
    
    public BigDecimal getRating() { return rating; }
    public void setRating(BigDecimal rating) { this.rating = rating; }
    
    public String getAvailableTime() { return availableTime; }
    public void setAvailableTime(String availableTime) { this.availableTime = availableTime; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public String getGame() { return game; }
    public void setGame(String game) { this.game = game; }
}