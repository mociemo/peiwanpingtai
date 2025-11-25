package com.playmate.dto;

import lombok.Data;

@Data
public class FollowRequest {
    private Long targetUserId;
    private String remark;
    
    // 为了兼容性保留这个方法
    public Long getFollowingId() {
        return this.targetUserId;
    }
}