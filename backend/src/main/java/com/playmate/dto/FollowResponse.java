package com.playmate.dto;

import com.playmate.entity.FollowStatus;
import java.time.LocalDateTime;

public class FollowResponse {
    private Long id;
    private UserInfo follower;
    private UserInfo following;
    private FollowStatus status;
    private LocalDateTime createTime;
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public UserInfo getFollower() {
        return follower;
    }
    
    public void setFollower(UserInfo follower) {
        this.follower = follower;
    }
    
    public UserInfo getFollowing() {
        return following;
    }
    
    public void setFollowing(UserInfo following) {
        this.following = following;
    }
    
    public FollowStatus getStatus() {
        return status;
    }
    
    public void setStatus(FollowStatus status) {
        this.status = status;
    }
    
    public LocalDateTime getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
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