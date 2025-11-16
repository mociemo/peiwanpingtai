package com.playmate.dto;

import java.time.LocalDateTime;

public class ShareResponse {
    private String shareId; // 分享ID
    private String shareUrl; // 分享链接
    private String title; // 分享标题
    private String description; // 分享描述
    private String imageUrl; // 分享图片
    private LocalDateTime expireTime; // 链接过期时间
    
    // Manual getters and setters
    public String getShareId() { return shareId; }
    public void setShareId(String shareId) { this.shareId = shareId; }
    
    public String getShareUrl() { return shareUrl; }
    public void setShareUrl(String shareUrl) { this.shareUrl = shareUrl; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    
    public LocalDateTime getExpireTime() { return expireTime; }
    public void setExpireTime(LocalDateTime expireTime) { this.expireTime = expireTime; }
}