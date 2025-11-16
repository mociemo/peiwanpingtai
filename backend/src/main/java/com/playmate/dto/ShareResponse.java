package com.playmate.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ShareResponse {
    private String shareId; // 分享ID
    private String shareUrl; // 分享链接
    private String title; // 分享标题
    private String description; // 分享描述
    private String imageUrl; // 分享图片
    private LocalDateTime expireTime; // 链接过期时间
}