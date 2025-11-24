package com.playmate.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class CreateOrderRequest {
    private Long playerId;
    private BigDecimal amount;
    private Integer duration;
    private String serviceType;
    private String requirements;
    private String contactInfo;
}