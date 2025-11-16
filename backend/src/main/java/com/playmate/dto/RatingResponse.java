package com.playmate.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class RatingResponse {
    private String id;
    private String orderId;
    private String raterId;
    private String raterName;
    private String raterAvatar;
    private String playerId;
    private String playerName;
    private Integer rating;
    private String comment;
    private List<String> tags;
    private LocalDateTime createTime;
}