package com.playmate.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserStatsResponse {
    private Long userId;
    private Integer followersCount;
    private Integer followingCount;
    private Integer postsCount;
    private Integer likedCount;
    private LocalDateTime lastActiveTime;
}