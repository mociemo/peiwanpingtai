package com.playmate.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Document(collection = "home_content")
public class HomeContent {
    @Id
    private String id;
    private String title;
    private String description;
    private String imageUrl;
    private String linkType; // "user", "post", "url", "activity"
    private String linkId; // 关联的ID，如果是url类型则为URL地址
    private Integer sortOrder; // 排序顺序，数字越小越靠前
    private Boolean isActive; // 是否启用
    private LocalDateTime startTime; // 开始展示时间
    private LocalDateTime endTime; // 结束展示时间
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}