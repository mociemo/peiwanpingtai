package com.playmate.dto;

import com.playmate.entity.PostType;
import com.playmate.entity.PostStatus;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Getter
@Setter
public class PostResponse {
    private Long id;
    private UserInfo user;
    private String content;
    private List<String> images;
    private List<String> tags;
    private PostType type;
    private PostStatus status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer likeCount;
    private Integer commentCount;
    private Integer shareCount;
    private Boolean isLiked;
    private Boolean isCollected;
    private Boolean isPinned;
    private String location;
    private String gameName;
    private String videoUrl;
    
    // Manual setters for Lombok compatibility
    public void setId(Long id) {
        this.id = id;
    }
    
    public void setUser(UserInfo user) {
        this.user = user;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public void setImages(List<String> images) {
        this.images = images;
    }
    
    public void setType(PostType type) {
        this.type = type;
    }
    
    public void setStatus(PostStatus status) {
        this.status = status;
    }
    
    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
    
    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }
    
    public void setLikeCount(Integer likeCount) {
        this.likeCount = likeCount;
    }
    
    public void setCommentCount(Integer commentCount) {
        this.commentCount = commentCount;
    }
    
    public void setShareCount(Integer shareCount) {
        this.shareCount = shareCount;
    }
    
    public void setIsLiked(Boolean isLiked) {
        this.isLiked = isLiked;
    }
    
    public void setCollected(Boolean collected) {
        this.isCollected = collected;
    }
    
    public void setPinned(Boolean pinned) {
        this.isPinned = pinned;
    }
    
    @Data
    public static class UserInfo {
        private Long id;
        private String username;
        private String avatar;
        
        // Manual setters for Lombok compatibility
        public void setId(Long id) {
            this.id = id;
        }
        
        public void setUsername(String username) {
            this.username = username;
        }
        
        public void setAvatar(String avatar) {
            this.avatar = avatar;
        }
    }
}