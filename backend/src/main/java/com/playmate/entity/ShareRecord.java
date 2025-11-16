package com.playmate.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "share_records")
public class ShareRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "share_id", unique = true)
    private String shareId; // 分享链接的唯一标识
    
    @Column(name = "user_id", nullable = false)
    private Long userId; // 分享者ID
    
    @Column(name = "share_type", nullable = false)
    private String shareType; // 分享类型: "user", "post", "order"
    
    @Column(name = "content_id", nullable = false)
    private String contentId; // 分享内容的ID
    
    @Column(name = "platform", nullable = false)
    private String platform; // 分享平台: "wechat", "qq", "weibo" 等
    
    @Column(name = "create_time", nullable = false)
    private LocalDateTime createTime; // 创建时间
    
    @Column(name = "expire_time")
    private LocalDateTime expireTime; // 过期时间
    
    @Column(name = "view_count", nullable = false)
    private Integer viewCount = 0; // 浏览次数
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
    
    // Manual getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getShareId() { return shareId; }
    public void setShareId(String shareId) { this.shareId = shareId; }
    
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    
    public String getShareType() { return shareType; }
    public void setShareType(String shareType) { this.shareType = shareType; }
    
    public String getContentId() { return contentId; }
    public void setContentId(String contentId) { this.contentId = contentId; }
    
    public String getPlatform() { return platform; }
    public void setPlatform(String platform) { this.platform = platform; }
    
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    
    public LocalDateTime getExpireTime() { return expireTime; }
    public void setExpireTime(LocalDateTime expireTime) { this.expireTime = expireTime; }
    
    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
}