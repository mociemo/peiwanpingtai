package com.playmate.dto;

import java.time.LocalDateTime;

public class UserStatsResponse {
    private Long userId;
    private Integer followersCount;
    private Integer followingCount;
    private Integer postsCount;
    private Integer likedCount;
    private LocalDateTime lastActiveTime;
    
    public Long getUserId() {
        return userId;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }
    
    public Integer getFollowersCount() {
        return followersCount;
    }
    
    public void setFollowersCount(Integer followersCount) {
        this.followersCount = followersCount;
    }
    
    public Integer getFollowingCount() {
        return followingCount;
    }
    
    public void setFollowingCount(Integer followingCount) {
        this.followingCount = followingCount;
    }
    
    public Integer getPostsCount() {
        return postsCount;
    }
    
    public void setPostsCount(Integer postsCount) {
        this.postsCount = postsCount;
    }
    
    public Integer getLikedCount() {
        return likedCount;
    }
    
    public void setLikedCount(Integer likedCount) {
        this.likedCount = likedCount;
    }
    
    public LocalDateTime getLastActiveTime() {
        return lastActiveTime;
    }
    
    public void setLastActiveTime(LocalDateTime lastActiveTime) {
        this.lastActiveTime = lastActiveTime;
    }
}