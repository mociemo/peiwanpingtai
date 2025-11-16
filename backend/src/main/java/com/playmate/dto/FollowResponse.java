package com.playmate.dto;

import com.playmate.entity.FollowStatus;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FollowResponse {
    private Long id;
    private UserInfo follower;
    private UserInfo following;
    private FollowStatus status;
    private LocalDateTime createTime;
    
    @Data
    public static class UserInfo {
        private Long id;
        private String username;
        private String avatar;
    }
}