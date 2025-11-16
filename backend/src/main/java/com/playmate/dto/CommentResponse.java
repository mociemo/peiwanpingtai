package com.playmate.dto;

import com.playmate.entity.CommentStatus;
import java.time.LocalDateTime;
import java.util.List;

public class CommentResponse {
    private Long id;
    private Long postId;
    private UserInfo user;
    private UserInfo replyToUser;
    private String content;
    private Long parentId;
    private CommentStatus status;
    private Integer likeCount;
    private Boolean isLiked;
    private LocalDateTime createTime;
    private List<CommentResponse> replies;
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getPostId() {
        return postId;
    }
    
    public void setPostId(Long postId) {
        this.postId = postId;
    }
    
    public UserInfo getUser() {
        return user;
    }
    
    public void setUser(UserInfo user) {
        this.user = user;
    }
    
    public UserInfo getReplyToUser() {
        return replyToUser;
    }
    
    public void setReplyToUser(UserInfo replyToUser) {
        this.replyToUser = replyToUser;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public Long getParentId() {
        return parentId;
    }
    
    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }
    
    public CommentStatus getStatus() {
        return status;
    }
    
    public void setStatus(CommentStatus status) {
        this.status = status;
    }
    
    public Integer getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(Integer likeCount) {
        this.likeCount = likeCount;
    }
    
    public Boolean getIsLiked() {
        return isLiked;
    }
    
    public void setIsLiked(Boolean isLiked) {
        this.isLiked = isLiked;
    }
    
    public LocalDateTime getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
    
    public List<CommentResponse> getReplies() {
        return replies;
    }
    
    public void setReplies(List<CommentResponse> replies) {
        this.replies = replies;
    }
    
    public static class UserInfo {
        private Long id;
        private String username;
        private String avatar;
        
        public Long getId() {
            return id;
        }
        
        public void setId(Long id) {
            this.id = id;
        }
        
        public String getUsername() {
            return username;
        }
        
        public void setUsername(String username) {
            this.username = username;
        }
        
        public String getAvatar() {
            return avatar;
        }
        
        public void setAvatar(String avatar) {
            this.avatar = avatar;
        }
    }
}