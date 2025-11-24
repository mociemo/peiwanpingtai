package com.playmate.dto;

import lombok.Data;

@Data
public class CommentRequest {
    private String content;
    private Long parentId;
    private Long replyToUserId;
}