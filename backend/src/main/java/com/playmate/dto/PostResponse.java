package com.playmate.dto;

import com.playmate.entity.PostType;
import com.playmate.entity.PostStatus;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
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
    
    @Data
    public static class UserInfo {
        private Long id;
        private String username;
        private String avatar;
    }
}