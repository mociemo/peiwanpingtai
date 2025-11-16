package com.playmate.dto;

import lombok.Data;

@Data
public class ShareRequest {
    private String userId; // 分享者ID
    private String shareType; // 分享类型: "user", "post", "order"
    private String shareId; // 分享内容的ID
    private String platform; // 分享平台: "wechat", "qq", "weibo" 等
}