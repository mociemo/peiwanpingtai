package com.playmate.dto;

public class ShareRequest {
    private Long userId; // 分享者ID
    private String shareType; // 分享类型: "user", "post", "order"
    private String shareId; // 分享内容的ID
    private String platform; // 分享平台: "wechat", "qq", "weibo" 等
    
    // Manual getters and setters
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    
    public String getShareType() { return shareType; }
    public void setShareType(String shareType) { this.shareType = shareType; }
    
    public String getShareId() { return shareId; }
    public void setShareId(String shareId) { this.shareId = shareId; }
    
    public String getPlatform() { return platform; }
    public void setPlatform(String platform) { this.platform = platform; }
}