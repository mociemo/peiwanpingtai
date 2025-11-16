package com.playmate.dto;

import lombok.Data;

@Data
public class FollowRequest {
    private Long followingId;
    private String remark;
    
    public Long getTargetUserId() {
        return this.followingId;
    }
}