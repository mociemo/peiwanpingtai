package com.playmate.dto;

import lombok.Data;

@Data
public class RatingRequest {
    private String orderId;
    private Integer rating; // 1-5星评分
    private String comment;
    private List<String> tags; // 评价标签，如"技术好"、"态度好"等
}