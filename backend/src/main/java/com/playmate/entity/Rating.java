package com.playmate.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Document(collection = "ratings")
public class Rating {
    @Id
    private String id;
    private String orderId;
    private String raterId;
    private String playerId;
    private Integer rating;
    private String comment;
    private List<String> tags;
    private LocalDateTime createTime;
}