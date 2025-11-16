package com.playmate.dto;

import com.playmate.entity.CommentStatus;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
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
    
    @Data
    public static class UserInfo {
        private Long id;
        private String username;
        private String avatar;
    }
}