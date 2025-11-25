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
    
    @ManyToOne
    @JoinColumn(name = "game_category_id")
    private GameCategory gameCategory;
    
    @Column(nullable = false)
    private String game;
    
    @Column(name = "price", nullable = false, precision = 10, scale = 2)
    private BigDecimal price;
    
    @Column
    private String level;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PlayerStatus status = PlayerStatus.AVAILABLE;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    // 扩展字段（用于更完整的陪玩达人功能）
    @Column(name = "real_name")
    private String realName;
    
    @Column(name = "id_card")
    private String idCard;
    
    @Column(columnDefinition = "JSON")
    private String skillTags;
    
    @Lob
    private String introduction;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "certification_status")
    private CertificationStatus certificationStatus = CertificationStatus.PENDING;
    
    @Column(name = "total_orders", nullable = false)
    private Integer totalOrders = 0;
    
    @Column(precision = 3, scale = 2, nullable = false)
    private BigDecimal rating = BigDecimal.valueOf(5.0);
    
    @Column(columnDefinition = "JSON")
    private String availableTime;
    
    public enum PlayerStatus {
        AVAILABLE, BUSY, OFFLINE
    }
    
    public enum CertificationStatus {
        PENDING, APPROVED, REJECTED
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
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public GameCategory getGameCategory() { return gameCategory; }
    public void setGameCategory(GameCategory gameCategory) { this.gameCategory = gameCategory; }
    
    public String getGame() { return game; }
    public void setGame(String game) { this.game = game; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    
    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public PlayerStatus getStatus() { return status; }
    public void setStatus(PlayerStatus status) { this.status = status; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
    
    public String getIdCard() { return idCard; }
    public void setIdCard(String idCard) { this.idCard = idCard; }
    
    public String getSkillTags() { return skillTags; }
    public void setSkillTags(String skillTags) { this.skillTags = skillTags; }
    
    public BigDecimal getServicePrice() { return price; } // 兼容旧方法
    public void setServicePrice(BigDecimal servicePrice) { this.price = servicePrice; }
    
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
}