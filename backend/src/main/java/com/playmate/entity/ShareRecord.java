package com.playmate.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Document(collection = "share_records")
public class ShareRecord {
    @Id
    private String id;
    private String shareId; // 分享链接的唯一标识
    private String userId; // 分享者ID
    private String shareType; // 分享类型: "user", "post", "order"
    private String contentId; // 分享内容的ID
    private String platform; // 分享平台: "wechat", "qq", "weibo" 等
    private LocalDateTime createTime; // 创建时间
    private LocalDateTime expireTime; // 过期时间
    private Integer viewCount; // 浏览次数
}